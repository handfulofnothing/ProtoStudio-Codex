import Foundation
import Combine

/// Coordinates project lifecycle, compilation, and preview reloads.
final class ProjectController: ObservableObject {
    @Published var state = ProjectState()

    private let compiler = CompilerService()
    private var server: LocalHTTPServer?
    private var cancellables = Set<AnyCancellable>()
    private let fileManager = FileManager.default

    init() {
        state.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }

    func start() {
        guard state.projectURL == nil else { return }
        let projectFolder = prepareDefaultProject()
        state.projectURL = projectFolder
        loadProject()
        startServer(root: projectFolder)
    }

    // MARK: - Project Loading

    private func prepareDefaultProject() -> URL {
        let base = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first ?? URL(fileURLWithPath: NSTemporaryDirectory())
        let projectFolder = base.appendingPathComponent("FramerClassicProject", isDirectory: true)
        let resources = Bundle.main.resourceURL ?? Bundle.main.bundleURL

        if !fileManager.fileExists(atPath: projectFolder.path) {
            try? fileManager.createDirectory(at: projectFolder, withIntermediateDirectories: true)
        }

        // Copy template files if missing
        let templateFiles = ["index.html", "app.coffee"]
        for file in templateFiles {
            let dest = projectFolder.appendingPathComponent(file)
            if !fileManager.fileExists(atPath: dest.path) {
                let source = resources.appendingPathComponent(file)
                try? fileManager.copyItem(at: source, to: dest)
            }
        }

        // Ensure initial app.js exists
        let appJS = projectFolder.appendingPathComponent("app.js")
        if !fileManager.fileExists(atPath: appJS.path) {
            try? "console.log('Ready');".write(to: appJS, atomically: true, encoding: .utf8)
        }

        return projectFolder
    }

    private func loadProject() {
        guard let projectURL = state.projectURL else { return }
        let coffeeURL = projectURL.appendingPathComponent("app.coffee")
        if let contents = try? String(contentsOf: coffeeURL) {
            state.coffeeScript = contents
        }
    }

    // MARK: - Save & Compile

    func handleSaveShortcut() {
        saveCoffeeScript()
        compileAndReload()
    }

    private func saveCoffeeScript() {
        guard let projectURL = state.projectURL else { return }
        let coffeeURL = projectURL.appendingPathComponent("app.coffee")
        try? state.coffeeScript.write(to: coffeeURL, atomically: true, encoding: .utf8)
    }

    func compileAndReload() {
        guard let projectURL = state.projectURL else { return }
        let result = compiler.compile(coffee: state.coffeeScript)

        switch result {
        case .success(let js):
            let outputURL = projectURL.appendingPathComponent("app.js")
            do {
                try js.write(to: outputURL, atomically: true, encoding: .utf8)
                state.compileError = nil
                state.reloadID = UUID()
            } catch {
                state.compileError = CompileError(message: "Failed to write app.js: \(error.localizedDescription)")
            }
        case .failure(let error):
            state.compileError = error
        }
    }

    // MARK: - HTTP Server

    private func startServer(root: URL) {
        server = LocalHTTPServer(rootDirectory: root)
        server?.start()
        state.serverPort = server?.port
    }
}

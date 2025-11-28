import Foundation
import Combine

/// Coordinates project lifecycle, compilation, and preview reloads.
final class ProjectController: ObservableObject {
    @Published var state: ProjectState
    @Published var reloadID = UUID()

    private let compiler: CompilerService
    private var httpServer: LocalHTTPServer?
    private let fileManager = FileManager.default

    init(projectURL: URL, compiler: CompilerService = try! CompilerService()) throws {
        self.compiler = compiler

        if !fileManager.fileExists(atPath: projectURL.path) {
            try fileManager.createDirectory(at: projectURL, withIntermediateDirectories: true)
        }

        let projectName = projectURL.lastPathComponent
        let coffeeScriptText = try Self.loadOrCreateCoffeeFile(at: projectURL, fileManager: fileManager)
        try Self.ensureTemplateFiles(at: projectURL, fileManager: fileManager)

        self.state = ProjectState(
            projectName: projectName,
            projectURL: projectURL,
            coffeeScriptText: coffeeScriptText,
            hasUnsavedChanges: false,
            lastCompileError: nil,
            serverPort: nil
        )

        try startServer()
    }

    // MARK: - Project Files

    func loadProjectFiles() throws {
        let coffeeURL = state.projectURL.appendingPathComponent("app.coffee")
        let contents = try String(contentsOf: coffeeURL)
        state.coffeeScriptText = contents
        state.hasUnsavedChanges = false
    }

    func saveCoffeeScript(_ text: String) throws {
        let coffeeURL = state.projectURL.appendingPathComponent("app.coffee")
        try text.write(to: coffeeURL, atomically: true, encoding: .utf8)
        state.hasUnsavedChanges = false
    }

    // MARK: - Save & Compile

    func handleSaveShortcut() {
        do {
            try saveCoffeeScript(state.coffeeScriptText)
            compileAndReload()
        } catch {
            state.lastCompileError = CompileError(message: error.localizedDescription, line: nil)
        }
    }

    func compileAndReload() {
        let source = state.coffeeScriptText
        switch compiler.compile(coffee: source) {
        case .success(let js):
            do {
                let jsURL = state.projectURL.appendingPathComponent("app.js")
                try js.write(to: jsURL, atomically: true, encoding: .utf8)
                state.lastCompileError = nil
                bumpReloadID()
            } catch {
                state.lastCompileError = CompileError(message: "Failed to write app.js: \(error.localizedDescription)", line: nil)
            }
        case .failure(let error):
            state.lastCompileError = error
        }
    }

    func bumpReloadID() {
        reloadID = UUID()
    }

    // MARK: - Preview

    var previewURL: URL? {
        guard let port = state.serverPort else { return nil }
        return URL(string: "http://localhost:\(port)/index.html?reload=\(reloadID)")
    }

    // MARK: - Server

    private func startServer() throws {
        let server = LocalHTTPServer(rootURL: state.projectURL)
        try server.start()
        httpServer = server
        state.serverPort = Int(server.port ?? 0)
    }

    // MARK: - Templates

    private static func loadOrCreateCoffeeFile(at projectURL: URL, fileManager: FileManager) throws -> String {
        let coffeeURL = projectURL.appendingPathComponent("app.coffee")
        if let existing = try? String(contentsOf: coffeeURL) {
            return existing
        }

        let defaultCoffee = try defaultResource(named: "app", withExtension: "coffee")
        try defaultCoffee.write(to: coffeeURL, atomically: true, encoding: .utf8)
        return defaultCoffee
    }

    private static func ensureTemplateFiles(at projectURL: URL, fileManager: FileManager) throws {
        let indexURL = projectURL.appendingPathComponent("index.html")
        if !fileManager.fileExists(atPath: indexURL.path) {
            let html = try defaultResource(named: "index", withExtension: "html")
            try html.write(to: indexURL, atomically: true, encoding: .utf8)
        }

        let assetsURL = projectURL.appendingPathComponent("assets")
        if !fileManager.fileExists(atPath: assetsURL.path) {
            try fileManager.createDirectory(at: assetsURL, withIntermediateDirectories: true)
        }
    }

    private static func defaultResource(named name: String, withExtension ext: String) throws -> String {
        guard let url = Bundle.main.url(forResource: name, withExtension: ext) else {
            throw NSError(domain: "ProjectController", code: 10, userInfo: [NSLocalizedDescriptionKey: "Missing template \(name).\(ext)"])
        }
        return try String(contentsOf: url)
    }
}

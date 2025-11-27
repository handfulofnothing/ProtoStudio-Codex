import SwiftUI

extension Notification.Name {
    static let framerSaveShortcut = Notification.Name("framerSaveShortcut")
}

@main
struct FramerClassicApp: App {
    @StateObject private var controller: ProjectController

    init() {
        let fm = FileManager.default
        let base = fm.urls(for: .documentDirectory, in: .userDomainMask).first ?? fm.temporaryDirectory
        let projectURL = base.appendingPathComponent("FramerClassicProject", isDirectory: true)
        if !fm.fileExists(atPath: projectURL.path) {
            try? fm.createDirectory(at: projectURL, withIntermediateDirectories: true)
        }

        if let controller = try? ProjectController(projectURL: projectURL) {
            _controller = StateObject(wrappedValue: controller)
        } else {
            let compiler = (try? CompilerService()) ?? (try! CompilerService())
            let fallback = try! ProjectController(projectURL: projectURL, compiler: compiler)
            _controller = StateObject(wrappedValue: fallback)
        }
    }

    var body: some Scene {
        WindowGroup {
            RootSplitView(controller: controller)
        }
        .commands {
            CommandGroup(replacing: .saveItem) {
                Button("Save Project") {
                    NotificationCenter.default.post(name: .framerSaveShortcut, object: nil)
                }
                .keyboardShortcut("s", modifiers: [.command])
            }
        }
    }
}

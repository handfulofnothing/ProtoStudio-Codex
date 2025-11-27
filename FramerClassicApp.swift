import SwiftUI

@main
struct FramerClassicApp: App {
    @StateObject private var controller = ProjectController()

    var body: some Scene {
        WindowGroup {
            RootSplitView()
                .environmentObject(controller)
                .onAppear {
                    controller.start()
                }
        }
        .commands {
            CommandGroup(after: .saveItem) {
                Button("Save Project", action: controller.handleSaveShortcut)
                    .keyboardShortcut("s", modifiers: [.command])
            }
        }
    }
}

import SwiftUI

struct RootSplitView: View {
    @ObservedObject var controller: ProjectController

    var body: some View {
        NavigationSplitView {
            editor
                .frame(minWidth: 320)
        } detail: {
            preview
                .frame(minWidth: 320)
                .background(Color(NSColor(calibratedWhite: 0.1, alpha: 1)))
        }
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button("View Options") {}
            }
            ToolbarItem(placement: .principal) {
                Text(controller.state.projectName)
                    .font(.headline)
            }
            ToolbarItem(placement: .automatic) {
                Button(action: controller.compileAndReload) {
                    Label("Reload", systemImage: "arrow.clockwise")
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .framerSaveShortcut)) { _ in
            controller.handleSaveShortcut()
        }
    }

    private var editor: some View {
        CodeEditorView(
            text: Binding(
                get: { controller.state.coffeeScriptText },
                set: { newValue in
                    controller.state.coffeeScriptText = newValue
                    controller.state.hasUnsavedChanges = true
                }
            ),
            onTextChange: { _ in
                controller.state.hasUnsavedChanges = true
                controller.state.lastCompileError = nil
            }
        )
        .overlay(alignment: .top) {
            if let error = controller.state.lastCompileError {
                ErrorBannerView(error: error)
                    .transition(.move(edge: .top))
            }
        }
    }

    private var preview: some View {
        WebPreviewView(
            url: controller.previewURL,
            reloadID: controller.reloadID
        )
    }
}

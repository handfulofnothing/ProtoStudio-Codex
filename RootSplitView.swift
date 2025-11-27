import SwiftUI

struct RootSplitView: View {
    @EnvironmentObject var controller: ProjectController

    var body: some View {
        NavigationView {
            editor
                .frame(minWidth: 320)
            preview
                .frame(minWidth: 320)
        }
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Text(projectTitle)
                    .font(.headline)
            }
            ToolbarItem(placement: .automatic) {
                Button(action: controller.handleSaveShortcut) {
                    Label("Reload", systemImage: "arrow.clockwise")
                }
            }
        }
    }

    private var editor: some View {
        ZStack(alignment: .top) {
            CodeEditorView(text: Binding(get: {
                controller.state.coffeeScript
            }, set: { newValue in
                controller.state.coffeeScript = newValue
            })) { newValue in
                controller.state.coffeeScript = newValue
                controller.state.compileError = nil
            }
            if let error = controller.state.compileError {
                ErrorBannerView(error: error)
                    .shadow(radius: 4)
                    .transition(.move(edge: .top))
                    .zIndex(1)
            }
        }
    }

    private var preview: some View {
        WebPreviewView(url: controller.state.previewURL, reloadID: controller.state.reloadID)
    }

    private var projectTitle: String {
        controller.state.projectURL?.lastPathComponent ?? "Framer Classic"
    }
}

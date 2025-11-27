import Foundation
import Combine

final class ProjectState: ObservableObject {
    @Published var projectURL: URL?
    @Published var coffeeScript: String = ""
    @Published var compileError: CompileError?
    @Published var reloadID: UUID = UUID()
    @Published var serverPort: UInt16?

    var previewURL: URL? {
        guard let port = serverPort else { return nil }
        return URL(string: "http://localhost:\(port)/index.html?reload=\(reloadID)")
    }
}

import Foundation

struct ProjectState {
    var projectName: String
    var projectURL: URL

    var coffeeScriptText: String
    var hasUnsavedChanges: Bool

    var lastCompileError: CompileError?
    var serverPort: Int?
}

struct CompileError: Identifiable, Error {
    let id = UUID()
    let message: String
    let line: Int?
}

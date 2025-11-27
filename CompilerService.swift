import Foundation
import JavaScriptCore

/// Handles CoffeeScript -> JavaScript compilation via JavaScriptCore.
final class CompilerService {
    private let context: JSContext

    init() throws {
        guard let context = JSContext() else {
            throw NSError(domain: "CompilerService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to create JSContext"])
        }
        self.context = context

        context.exceptionHandler = { _, exception in
            if let exception = exception {
                print("JavaScript exception: \(exception)")
            }
        }

        guard let compilerURL = ResourceBundle.bundle.url(forResource: "coffee-script", withExtension: "js") else {
            throw NSError(domain: "CompilerService", code: 2, userInfo: [NSLocalizedDescriptionKey: "Missing bundled coffee-script.js"])
        }
        let script = try String(contentsOf: compilerURL)
        context.evaluateScript(script)

        guard context.objectForKeyedSubscript("CoffeeScript")?.objectForKeyedSubscript("compile") != nil else {
            throw NSError(domain: "CompilerService", code: 3, userInfo: [NSLocalizedDescriptionKey: "CoffeeScript.compile unavailable"])
        }
    }

    func compile(coffee: String) -> Result<String, CompileError> {
        let compileFunction = context.objectForKeyedSubscript("CoffeeScript")?.objectForKeyedSubscript("compile")
        let options: [String: Any] = ["bare": true]

        context.exception = nil
        let result = compileFunction?.call(withArguments: [coffee, options])

        if let exception = context.exception {
            context.exception = nil
            let message = exception.toString() ?? "Unknown error"
            let line = exception.objectForKeyedSubscript("location")?.objectForKeyedSubscript("first_line")?.toInt32()
            return .failure(CompileError(message: message, line: line != nil ? Int(line!) + 1 : nil))
        }

        guard let code = result?.toString() else {
            return .failure(CompileError(message: "Compilation failed", line: nil))
        }

        return .success(code)
    }
}

import Foundation
import JavaScriptCore

struct CompileError: Error, Identifiable {
    let id = UUID()
    let message: String
    let line: Int?
}

/// Wraps the bundled CoffeeScript compiler via JavaScriptCore.
final class CompilerService {
    private let context: JSContext?

    init() {
        context = JSContext()
        guard let context = context else { return }
        context.exceptionHandler = { _, exception in
            if let exception = exception {
                print("JavaScript exception: \(exception)")
            }
        }

        if let url = Bundle.main.url(forResource: "coffee-script", withExtension: "js"),
           let script = try? String(contentsOf: url) {
            context.evaluateScript(script)
        }
    }

    func compile(coffee: String) -> Result<String, CompileError> {
        guard let context = context else {
            return .failure(CompileError(message: "JavaScript engine unavailable", line: nil))
        }

        let coffeeEscaped = coffee.replacingOccurrences(of: "\\", with: "\\\\").replacingOccurrences(of: "`", with: "\\`")
        let script = """
        (function() {
            try {
                return { ok: true, code: CoffeeScript.compile(`\(coffeeEscaped)`, {bare: true}) };
            } catch (e) {
                return { ok: false, message: e.toString(), line: e.location && e.location.first_line + 1 };
            }
        })();
        """

        guard let result = context.evaluateScript(script) else {
            return .failure(CompileError(message: "Compilation failed", line: nil))
        }

        if result.forProperty("ok").toBool() {
            let code = result.forProperty("code").toString() ?? ""
            return .success(code)
        }

        let message = result.forProperty("message").toString() ?? "Unknown error"
        let line = result.forProperty("line").toInt32()
        return .failure(CompileError(message: message, line: line > 0 ? Int(line) : nil))
    }
}

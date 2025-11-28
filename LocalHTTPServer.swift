import Foundation
import Network

/// Minimal static file HTTP server for previewing the project folder.
final class LocalHTTPServer {
    let rootURL: URL
    private(set) var port: Int?

    private var listener: NWListener?
    private let queue = DispatchQueue(label: "LocalHTTPServer.queue")

    init(rootURL: URL) {
        self.rootURL = rootURL
    }

    func start() throws {
        let parameters = NWParameters.tcp
        let listener = try NWListener(using: parameters, on: .any)
        self.listener = listener

        listener.stateUpdateHandler = { [weak self] state in
            switch state {
            case .ready:
                if let rawPort = listener.port?.rawValue {
                    self?.port = Int(rawPort)
                }
            default:
                break
            }
        }

        listener.newConnectionHandler = { [weak self] connection in
            connection.start(queue: self?.queue ?? .main)
            self?.receive(on: connection)
        }

        listener.start(queue: queue)
    }

    func stop() {
        listener?.cancel()
        listener = nil
    }

    private func receive(on connection: NWConnection) {
        connection.receive(minimumIncompleteLength: 1, maximumLength: 65536) { [weak self] data, _, isComplete, error in
            guard let self = self else { return }
            defer { if isComplete || error != nil { connection.cancel() } }

            guard let data = data, !data.isEmpty, let request = String(data: data, encoding: .utf8) else { return }
            let path = self.parsePath(from: request)
            let response = self.response(forPath: path)
            connection.send(content: response, completion: .contentProcessed { _ in
                connection.cancel()
            })
        }
    }

    private func parsePath(from request: String) -> String {
        guard let firstLine = request.split(separator: "\n").first else { return "/" }
        let parts = firstLine.split(separator: " ")
        guard parts.count > 1 else { return "/" }
        let rawPath = String(parts[1])
        if let queryIndex = rawPath.firstIndex(of: "?") {
            return String(rawPath[..<queryIndex])
        }
        return rawPath
    }

    private func response(forPath path: String) -> Data {
        var trimmed = path
        if trimmed.hasPrefix("/") { trimmed.removeFirst() }
        if trimmed.isEmpty { trimmed = "index.html" }

        let target = rootURL.appendingPathComponent(trimmed)
        guard FileManager.default.fileExists(atPath: target.path) else {
            return buildResponse(status: "404 Not Found", mime: "text/plain", body: Data("Not Found".utf8))
        }

        let mime = mimeType(for: target.pathExtension)
        guard let body = try? Data(contentsOf: target) else {
            return buildResponse(status: "500 Internal Server Error", mime: "text/plain", body: Data("Error reading file".utf8))
        }

        return buildResponse(status: "200 OK", mime: mime, body: body)
    }

    private func buildResponse(status: String, mime: String, body: Data) -> Data {
        var headers = "HTTP/1.1 \(status)\r\n"
        headers += "Content-Type: \(mime)\r\n"
        headers += "Content-Length: \(body.count)\r\n"
        headers += "Connection: close\r\n\r\n"
        var data = Data(headers.utf8)
        data.append(body)
        return data
    }

    private func mimeType(for ext: String) -> String {
        switch ext.lowercased() {
        case "html", "htm": return "text/html"
        case "js": return "application/javascript"
        case "css": return "text/css"
        case "png": return "image/png"
        case "jpg", "jpeg": return "image/jpeg"
        case "gif": return "image/gif"
        case "svg": return "image/svg+xml"
        default: return "application/octet-stream"
        }
    }
}

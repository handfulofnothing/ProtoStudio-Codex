import Foundation
import Network

/// Minimal static file HTTP server for previewing the project folder.
final class LocalHTTPServer {
    private let listener: NWListener
    private let rootDirectory: URL
    private let queue = DispatchQueue(label: "LocalHTTPServer")
    private(set) var port: UInt16?

    init?(rootDirectory: URL) {
        self.rootDirectory = rootDirectory
        do {
            listener = try NWListener(using: .tcp, on: .any)
        } catch {
            print("Failed to start listener: \(error)")
            return nil
        }
    }

    func start() {
        listener.newConnectionHandler = { [weak self] connection in
            self?.handle(connection: connection)
        }

        listener.stateUpdateHandler = { [weak self] state in
            switch state {
            case .ready:
                if let port = self?.listener.port?.rawValue {
                    self?.port = port
                }
            default:
                break
            }
        }

        listener.start(queue: queue)
    }

    private func handle(connection: NWConnection) {
        connection.start(queue: queue)
        receiveRequest(on: connection)
    }

    private func receiveRequest(on connection: NWConnection) {
        connection.receive(minimumIncompleteLength: 1, maximumLength: 65536) { [weak self] data, _, isComplete, error in
            guard let self = self else { return }
            if let data = data, !data.isEmpty, let request = String(data: data, encoding: .utf8) {
                let path = parsePath(from: request)
                let response = self.responseForPath(path)
                connection.send(content: response, completion: .contentProcessed { _ in
                    connection.cancel()
                })
            }
            if isComplete || error != nil {
                connection.cancel()
            }
        }
    }

    private func parsePath(from request: String) -> String {
        let lines = request.split(separator: "\n")
        guard let first = lines.first else { return "/" }
        let components = first.split(separator: " ")
        guard components.count > 1 else { return "/" }
        let rawPath = String(components[1])
        if let queryIndex = rawPath.firstIndex(of: "?") {
            return String(rawPath[..<queryIndex])
        }
        return rawPath
    }

    private func responseForPath(_ path: String) -> Data {
        var filePath = path
        if filePath.hasPrefix("/") { filePath.removeFirst() }
        if filePath.isEmpty { filePath = "index.html" }

        let targetURL = rootDirectory.appendingPathComponent(filePath)
        let data: Data
        if let fileData = try? Data(contentsOf: targetURL) {
            data = fileData
        } else {
            let body = "Not Found"
            return buildResponse(status: "404 Not Found", mime: "text/plain", body: Data(body.utf8))
        }

        let mime = mimeType(for: targetURL.pathExtension)
        return buildResponse(status: "200 OK", mime: mime, body: data)
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

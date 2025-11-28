import SwiftUI
import WebKit
import AppKit

struct WebPreviewView: NSViewRepresentable {
    var url: URL?
    var reloadID: UUID

    func makeNSView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.setValue(false, forKey: "drawsBackground")
        webView.layer?.backgroundColor = NSColor(calibratedWhite: 0.12, alpha: 1).cgColor
        return webView
    }

    func updateNSView(_ webView: WKWebView, context: Context) {
        guard let url = url else { return }
        if context.coordinator.lastLoadedID != reloadID || webView.url != url {
            context.coordinator.lastLoadedID = reloadID
            webView.load(URLRequest(url: url))
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    final class Coordinator {
        var lastLoadedID = UUID()
    }
}

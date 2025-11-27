import SwiftUI
import WebKit

struct WebPreviewView: NSViewRepresentable {
    let url: URL?
    let reloadID: UUID

    func makeNSView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.allowsBackForwardNavigationGestures = false
        return webView
    }

    func updateNSView(_ webView: WKWebView, context: Context) {
        guard let url = url else { return }
        let request = URLRequest(url: url)
        if webView.url != url {
            webView.load(request)
        } else {
            webView.reload()
        }
    }
}

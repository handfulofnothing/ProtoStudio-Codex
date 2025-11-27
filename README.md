# ProtoStudio-Codex
Modern SwiftUI recreation of Framer Classic with live CoffeeScript preview.

## Project Files
- FramerClassicApp.swift – SwiftUI app entry point and save shortcut wiring.
- ProjectState.swift – Observable project model.
- ProjectController.swift – Project lifecycle, compile, and preview orchestration.
- CompilerService.swift – JavaScriptCore CoffeeScript compiler bridge.
- LocalHTTPServer.swift – Minimal static file server for WKWebView preview.
- CodeEditorView.swift – NSTextView-based CoffeeScript editor.
- WebPreviewView.swift – WKWebView wrapper that reloads on save.
- ErrorBannerView.swift – Compile error display overlay.
- RootSplitView.swift – Split UI between editor and preview.
- Resources/index.html – Preview shell loaded by WKWebView.
- Resources/app.coffee – Default CoffeeScript entry point.
- Resources/coffee-script.js – Bundled CoffeeScript compiler (replace with full build for production).

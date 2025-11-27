# ProtoStudio-Codex
Modern SwiftUI recreation of Framer Classic with live CoffeeScript preview.

See `instructions.md` for build/run guidance, including a helper script for Swift Package Manager.

## Components
- **FramerClassicApp.swift** – SwiftUI entry, custom ⌘S command posting `.framerSaveShortcut`.
- **ProjectState.swift** – Plain state container for project metadata, sources, and errors.
- **ProjectController.swift** – Loads templates, saves CoffeeScript, compiles, and orchestrates preview reloads.
- **CompilerService.swift** – JavaScriptCore bridge loading bundled `coffee-script.js` to compile CoffeeScript.
- **LocalHTTPServer.swift** – Minimal static server (NWListener) serving project files to WKWebView.
- **CodeEditorView.swift** – NSTextView wrapper with dark monospaced styling.
- **WebPreviewView.swift** – WKWebView wrapper that reloads index.html when `reloadID` changes.
- **ErrorBannerView.swift** – Red banner showing compile errors.
- **RootSplitView.swift** – Split interface with toolbar, editor, preview, and error overlay.
- **Resources/index.html** – Default HTML shell that loads `framer/framer.js` and compiles `app.coffee` in-browser via CoffeeScript.
- **Resources/app.coffee** – Default CoffeeScript entry point.
- **Resources/framer/** – Bundled `framer.js` placeholder runtime plus `coffee-script.js` for browser-side compilation.

## Behavior
Pressing ⌘S saves `app.coffee`, compiles it to `app.js`, clears errors on success, and reloads the preview served from the embedded HTTP server. Compilation failures leave the previous `app.js` intact and show the error banner in the editor pane.

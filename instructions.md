# Build and Run Instructions

These steps assume macOS with Xcode 15+ or the latest Command Line Tools installed.

## Prerequisites
- macOS 13 or newer
- Xcode 15 (or newer) **or** Swift 5.9 toolchain
- Network permission to bind to `localhost` (for the embedded HTTP server)

## Quick start (scripted)
Run the helper script from the repo root:

```
./scripts/build_and_run.sh
```

This script:
1. Builds the app with Swift Package Manager (SPM).
2. Launches the `FramerClassic` executable, which opens the SwiftUI window.

## Manual steps
If you prefer manual commands:

1. Build the executable:
   ```bash
   swift build
   ```

2. Run the app:
   ```bash
   swift run FramerClassic
   ```

3. The app creates/opens a project at `~/Documents/FramerClassicProject` by default. Press **⌘S** in the editor pane to save, compile, and reload the preview.

## Xcode
You can also open the package in Xcode (`File > Open Package...`), select the **FramerClassic** scheme, and press **Run**. Xcode will handle resources automatically via SwiftPM.

## Notes
- Resources (`Resources/index.html`, `app.coffee`, `framer/framer.js`, and `framer/coffee-script.js`) are bundled via SwiftPM and resolved at runtime through `ResourceBundle.bundle`.
- The local HTTP server picks an open port dynamically; the preview URL uses `http://localhost:<port>/index.html`.
- If you change system web content restrictions (e.g., App Transport Security), ensure localhost loads are permitted (default macOS settings allow this).

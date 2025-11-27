import Foundation

/// Provides a unified resource bundle regardless of whether the app is built via
/// Xcode or Swift Package Manager. SwiftPM exposes bundled resources through
/// `Bundle.module`, while Xcode uses `Bundle.main` for the app target.
enum ResourceBundle {
    static var bundle: Bundle {
        #if SWIFT_PACKAGE
        return Bundle.module
        #else
        return Bundle.main
        #endif
    }
}

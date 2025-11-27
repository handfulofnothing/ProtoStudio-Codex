import SwiftUI

struct ErrorBannerView: View {
    let error: CompileError

    var body: some View {
        VStack {
            Text(formattedMessage)
                .font(.caption)
                .padding(8)
        }
        .frame(maxWidth: .infinity)
        .background(Color.red.opacity(0.9))
        .foregroundColor(.white)
    }

    private var formattedMessage: String {
        if let line = error.line {
            return "Line \(line): \(error.message)"
        }
        return error.message
    }
}

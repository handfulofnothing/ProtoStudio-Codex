import SwiftUI

struct ErrorBannerView: View {
    let error: CompileError

    var body: some View {
        VStack {
            HStack(alignment: .top) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.white)
                VStack(alignment: .leading) {
                    Text("Compile Error")
                        .font(.headline)
                        .foregroundColor(.white)
                    Text(formattedMessage)
                        .font(.subheadline)
                        .foregroundColor(.white)
                }
                Spacer()
            }
            .padding()
        }
        .background(Color.red)
    }

    private var formattedMessage: String {
        if let line = error.line {
            return "Line \(line): \(error.message)"
        }
        return error.message
    }
}

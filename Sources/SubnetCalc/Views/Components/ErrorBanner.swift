import SwiftUI

struct ErrorBanner: View {
    let message: String
    
    var body: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
            Text(message)
            Spacer()
        }
        .padding()
        .background(Color.red.opacity(0.2))
        .foregroundColor(.red)
        .cornerRadius(8)
    }
}

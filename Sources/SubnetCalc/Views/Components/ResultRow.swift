import SwiftUI

struct ResultRow: View {
    let label: LocalizedStringKey
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .fontWeight(.semibold)
            Spacer()
            Text(value)
                .textSelection(.enabled)
            Button {
                NSPasteboard.general.clearContents()
                NSPasteboard.general.setString(value, forType: .string)
            } label: {
                Image(systemName: "doc.on.doc")
            }
            .buttonStyle(.plain)
            .help(Text("Copy"))
        }
        .padding(.vertical, 4)
    }
}

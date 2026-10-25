import SwiftUI

struct ExportButton: View {
    let textContent: String
    let csvContent: String
    
    var body: some View {
        Menu {
            Button("Copy as Text") {
                copyToClipboard(textContent)
            }
            Button("Copy as CSV") {
                copyToClipboard(csvContent)
            }
            Button("Save as CSV...") {
                saveAsCSV()
            }
        } label: {
            Label("Export", systemImage: "square.and.arrow.up")
        }
    }
    
    private func copyToClipboard(_ text: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
    }
    
    private func saveAsCSV() {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.commaSeparatedText]
        panel.nameFieldStringValue = "Export.csv"
        
        if panel.runModal() == .OK, let url = panel.url {
            try? csvContent.write(to: url, atomically: true, encoding: .utf8)
        }
    }
}

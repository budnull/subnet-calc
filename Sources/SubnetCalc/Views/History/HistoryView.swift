import SwiftUI

struct HistoryView: View {
    @StateObject private var viewModel = HistoryViewModel()
    @State private var showingClearConfirm = false
    
    var body: some View {
        VStack {
            HStack {
                Text("History")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Spacer()
                Button("Clear History") {
                    showingClearConfirm = true
                }
                .disabled(viewModel.entries.isEmpty)
                .alert("Are you sure?", isPresented: $showingClearConfirm) {
                    Button("Clear", role: .destructive) {
                        viewModel.clearHistory()
                    }
                    Button("Cancel", role: .cancel) {}
                }
            }
            .padding()
            
            if viewModel.entries.isEmpty {
                Spacer()
                Text("No history yet")
                    .foregroundColor(.secondary)
                Spacer()
            } else {
                Table(viewModel.entries) {
                    TableColumn("Date") { entry in
                        Text(entry.date, style: .date)
                    }
                    TableColumn("Type", value: \.type)
                    TableColumn("Input", value: \.input)
                    TableColumn("Summary", value: \.summary)
                }
            }
        }
        .onAppear {
            viewModel.load()
        }
    }
}

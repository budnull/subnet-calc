import SwiftUI
import NetworkCalcKit

struct IPv6View: View {
    @StateObject private var viewModel = IPv6ViewModel()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("IPv6")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                HStack {
                    TextField("e.g., 2001:db8::1/48", text: $viewModel.input)
                        .textFieldStyle(.roundedBorder)
                        .onSubmit { viewModel.calculate() }
                    
                    Button("Calculate") { viewModel.calculate() }
                        .keyboardShortcut(.return, modifiers: .command)
                    
                    Button("Clear") { viewModel.clear() }
                }
                
                if let error = viewModel.errorMessage {
                    ErrorBanner(message: error)
                }
                
                if let result = viewModel.result {
                    GroupBox("Results") {
                        VStack(spacing: 0) {
                            ResultRow(label: "Network Prefix", value: result.networkPrefix.description)
                            Divider()
                            ResultRow(label: "First Address", value: result.firstAddress.description)
                            Divider()
                            ResultRow(label: "Last Address", value: result.lastAddress.description)
                            Divider()
                            ResultRow(label: "Total Addresses", value: result.totalAddresses)
                        }
                        .padding()
                    }
                    
                    HStack {
                        Spacer()
                        ExportButton(textContent: viewModel.resultAsText(), csvContent: viewModel.resultAsCSV())
                    }
                }
                
                Spacer()
            }
            .padding()
        }
    }
}

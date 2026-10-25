import SwiftUI
import NetworkCalcKit

struct IPv4View: View {
    @StateObject private var viewModel = IPv4ViewModel()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("IPv4")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                HStack {
                    TextField("e.g., 192.168.1.10/24", text: $viewModel.input)
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
                            ResultRow(label: "Network Address", value: result.networkAddress.description)
                            Divider()
                            ResultRow(label: "Broadcast Address", value: result.broadcastAddress.description)
                            Divider()
                            ResultRow(label: "Subnet Mask", value: result.subnetMask.description)
                            Divider()
                            ResultRow(label: "Wildcard Mask", value: result.wildcardMask.description)
                            Divider()
                            ResultRow(label: "First Usable Host", value: result.firstUsableHost?.description ?? "-")
                            Divider()
                            ResultRow(label: "Last Usable Host", value: result.lastUsableHost?.description ?? "-")
                            Divider()
                            ResultRow(label: "Total Addresses", value: String(result.totalAddresses))
                            Divider()
                            ResultRow(label: "Usable Hosts", value: String(result.usableHosts))
                            Divider()
                            ResultRow(label: "Address Class", value: result.addressClass.rawValue)
                        }
                        .padding()
                    }
                    
                    BinaryRepresentationView(result: result)
                    
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

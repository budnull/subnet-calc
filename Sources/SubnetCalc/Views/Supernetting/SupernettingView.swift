import SwiftUI

struct SupernettingView: View {
    @StateObject private var viewModel = SupernettingViewModel()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Supernetting")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Enter at least two networks to calculate the summary route.")
                    .foregroundColor(.secondary)
                
                ForEach($viewModel.networkInputs) { $input in
                    HStack {
                        TextField("Network (e.g. 192.168.0.0/24)", text: $input.text)
                            .textFieldStyle(.roundedBorder)
                        
                        if viewModel.networkInputs.count > 2 {
                            Button(action: { viewModel.removeNetwork(id: input.id) }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                
                Button("Add Network") {
                    viewModel.addNetwork()
                }
                
                HStack {
                    Button("Calculate") { viewModel.calculate() }
                        .keyboardShortcut(.return, modifiers: .command)
                    Button("Clear") { viewModel.clear() }
                }
                
                if let error = viewModel.errorMessage {
                    ErrorBanner(message: error)
                }
                
                if let net = viewModel.resultNetwork, let p = viewModel.resultPrefix {
                    GroupBox("Aggregated Route") {
                        ResultRow(label: "Supernet", value: "\(net)/\(p)")
                    }
                }
                
                Spacer()
            }
            .padding()
        }
    }
}

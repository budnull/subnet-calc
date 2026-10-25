import SwiftUI

struct SubnettingView: View {
    @StateObject private var viewModel = SubnettingViewModel()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Subnetting")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            HStack {
                TextField("e.g., 192.168.1.0/24", text: $viewModel.networkInput)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit { viewModel.calculate() }
                
                Picker("Mode", selection: $viewModel.mode) {
                    ForEach(SubnettingMode.allCases, id: \.self) { mode in
                        Text(mode.localizedName).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 150)
            }
            
            if viewModel.mode == .equal {
                TextField("Number of subnets", text: $viewModel.numberOfSubnets)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit { viewModel.calculate() }
            } else {
                VLSMView(viewModel: viewModel)
            }
            
            HStack {
                Button("Calculate") { viewModel.calculate() }
                    .keyboardShortcut(.return, modifiers: .command)
                Button("Clear") { viewModel.clear() }
                
                if !viewModel.results.isEmpty {
                    Spacer()
                    ExportButton(textContent: viewModel.resultsAsText(), csvContent: viewModel.resultsAsCSV())
                }
            }
            
            if let error = viewModel.errorMessage {
                ErrorBanner(message: error)
            }
            
            if !viewModel.results.isEmpty {
                ResultTable(allocations: viewModel.results)
            }
            
            Spacer()
        }
        .padding()
    }
}

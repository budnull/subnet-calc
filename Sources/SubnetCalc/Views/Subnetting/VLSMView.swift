import SwiftUI

struct VLSMView: View {
    @ObservedObject var viewModel: SubnettingViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("VLSM Requirements")
                .font(.headline)
            
            ForEach($viewModel.vlsmRequirements) { $req in
                HStack {
                    TextField("Subnet name", text: $req.name)
                        .textFieldStyle(.roundedBorder)
                    
                    TextField("Host count", text: $req.hosts)
                        .textFieldStyle(.roundedBorder)
                    
                    Button(action: { viewModel.removeRequirement(id: req.id) }) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                    .buttonStyle(.plain)
                }
            }
            
            Button("Add Requirement") {
                viewModel.addRequirement()
            }
            .padding(.top, 5)
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
    }
}

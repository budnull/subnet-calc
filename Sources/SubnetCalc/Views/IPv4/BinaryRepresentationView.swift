import SwiftUI
import NetworkCalcKit

struct BinaryRepresentationView: View {
    let result: IPv4SubnetResult
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Binary Representation")
                .font(.headline)
            
            HStack(spacing: 0) {
                Text(result.binaryWithHighlight.network)
                    .foregroundColor(.blue)
                    .font(.system(.body, design: .monospaced))
                
                Text(result.binaryWithHighlight.host)
                    .foregroundColor(.orange)
                    .font(.system(.body, design: .monospaced))
            }
            
            HStack {
                Circle().fill(Color.blue).frame(width: 10, height: 10)
                Text("Network Bits")
                Circle().fill(Color.orange).frame(width: 10, height: 10)
                Text("Host Bits")
            }
            .font(.caption)
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
    }
}

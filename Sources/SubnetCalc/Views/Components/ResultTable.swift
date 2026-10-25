import SwiftUI
import NetworkCalcKit

struct ResultTable: View {
    let allocations: [SubnetAllocation]
    
    var body: some View {
        Table(allocations) {
            TableColumn("Name", value: \.name)
            TableColumn("Network") { a in
                Text("\(a.networkAddress.description)/\(a.prefixLength)")
            }
            TableColumn("Range") { a in
                Text("\(a.firstUsableHost?.description ?? "") - \(a.lastUsableHost?.description ?? "")")
            }
            TableColumn("Broadcast") { a in
                Text(a.broadcastAddress.description)
            }
            TableColumn("Usable Hosts") { a in
                Text(String(a.usableHosts))
            }
        }
    }
}

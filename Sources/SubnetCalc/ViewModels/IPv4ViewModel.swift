import SwiftUI
import NetworkCalcKit

class IPv4ViewModel: ObservableObject {
    @Published var input: String = ""
    @Published var result: IPv4SubnetResult?
    @Published var errorMessage: String?
    
    func calculate() {
        errorMessage = nil
        do {
            let res = try IPv4Calculator.calculate(input: input)
            result = res
            HistoryService.shared.add(entry: HistoryEntry(id: UUID(), date: Date(), type: "IPv4", input: input, summary: res.networkAddress.description))
        } catch let error as NetworkError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func clear() {
        input = ""
        result = nil
        errorMessage = nil
    }
    
    func resultAsText() -> String {
        guard let r = result else { return "" }
        return """
        Network Address: \(r.networkAddress.description)
        Broadcast Address: \(r.broadcastAddress.description)
        Subnet Mask: \(r.subnetMask.description)
        Wildcard Mask: \(r.wildcardMask.description)
        First Usable Host: \(r.firstUsableHost?.description ?? "-")
        Last Usable Host: \(r.lastUsableHost?.description ?? "-")
        Total Addresses: \(r.totalAddresses)
        Usable Hosts: \(r.usableHosts)
        """
    }
    
    func resultAsCSV() -> String {
        guard let r = result else { return "" }
        return """
        Field,Value
        Network Address,\(r.networkAddress.description)
        Broadcast Address,\(r.broadcastAddress.description)
        Subnet Mask,\(r.subnetMask.description)
        Wildcard Mask,\(r.wildcardMask.description)
        First Usable Host,\(r.firstUsableHost?.description ?? "-")
        Last Usable Host,\(r.lastUsableHost?.description ?? "-")
        Total Addresses,\(r.totalAddresses)
        Usable Hosts,\(r.usableHosts)
        """
    }
    
    func copyToClipboard(_ text: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
    }
}

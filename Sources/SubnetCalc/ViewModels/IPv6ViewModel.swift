import SwiftUI
import NetworkCalcKit

class IPv6ViewModel: ObservableObject {
    @Published var input: String = ""
    @Published var result: IPv6SubnetResult?
    @Published var errorMessage: String?
    
    func calculate() {
        errorMessage = nil
        do {
            let res = try IPv6Calculator.calculate(input: input)
            result = res
            HistoryService.shared.add(entry: HistoryEntry(id: UUID(), date: Date(), type: "IPv6", input: input, summary: res.networkPrefix.description))
        } catch {
            if let netErr = error as? NetworkError {
                errorMessage = netErr.localizedDescription
            } else {
                errorMessage = error.localizedDescription
            }
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
        Network Prefix: \(r.networkPrefix)
        First Address: \(r.firstAddress)
        Last Address: \(r.lastAddress)
        Total Addresses: \(r.totalAddresses)
        """
    }
    
    func resultAsCSV() -> String {
        guard let r = result else { return "" }
        return """
        Field,Value
        Network Prefix,\(r.networkPrefix)
        First Address,\(r.firstAddress)
        Last Address,\(r.lastAddress)
        Total Addresses,\(r.totalAddresses)
        """
    }
}

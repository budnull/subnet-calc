import SwiftUI
import NetworkCalcKit

struct NetworkInput: Identifiable {
    let id = UUID()
    var text: String = ""
}

class SupernettingViewModel: ObservableObject {
    @Published var networkInputs: [NetworkInput] = [NetworkInput(), NetworkInput()]
    @Published var resultNetwork: String?
    @Published var resultPrefix: String?
    @Published var errorMessage: String?
    
    func calculate() {
        errorMessage = nil
        var networks: [(IPv4Address, Int)] = []
        do {
            for input in networkInputs {
                if !input.text.isEmpty {
                    let parts = input.text.components(separatedBy: "/")
                    let ipStr = parts[0].trimmingCharacters(in: .whitespaces)
                    let ip = try IPv4Address(string: ipStr)
                    let prefix = parts.count > 1 ? (Int(parts[1].trimmingCharacters(in: .whitespaces)) ?? 24) : 24
                    networks.append((ip, prefix))
                }
            }
            guard networks.count >= 2 else {
                throw NetworkError.invalidInput("Enter at least two networks to aggregate.")
            }
            let result = try SupernettingCalculator.aggregate(networks: networks)
            resultNetwork = result.network.description
            resultPrefix = String(result.prefixLength)
            HistoryService.shared.add(entry: HistoryEntry(id: UUID(), date: Date(), type: "Supernetting", input: "\(networks.count) networks", summary: "\(result.network.description)/\(result.prefixLength)"))
        } catch {
            if let netErr = error as? NetworkError {
                errorMessage = netErr.localizedDescription
            } else {
                errorMessage = error.localizedDescription
            }
        }
    }
    
    func addNetwork() {
        networkInputs.append(NetworkInput())
    }
    
    func removeNetwork(id: UUID) {
        if networkInputs.count > 2 {
            networkInputs.removeAll { $0.id == id }
        }
    }
    
    func clear() {
        networkInputs = [NetworkInput(), NetworkInput()]
        resultNetwork = nil
        resultPrefix = nil
        errorMessage = nil
    }
}

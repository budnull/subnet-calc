import SwiftUI
import NetworkCalcKit

enum SubnettingMode: String, CaseIterable {
    case equal = "Equal"
    case vlsm = "VLSM"
    
    var localizedName: LocalizedStringKey {
        switch self {
        case .equal: return "Equal Division"
        case .vlsm: return "VLSM"
        }
    }
}

struct VLSMRequirementItem: Identifiable {
    let id = UUID()
    var name: String
    var hosts: String
}

class SubnettingViewModel: ObservableObject {
    @Published var networkInput: String = ""
    @Published var mode: SubnettingMode = .equal
    @Published var numberOfSubnets: String = ""
    @Published var vlsmRequirements: [VLSMRequirementItem] = []
    @Published var results: [SubnetAllocation] = []
    @Published var errorMessage: String?
    
    func calculate() {
        errorMessage = nil
        do {
            let components = networkInput.split(separator: "/")
            guard components.count == 2, let prefix = Int(components[1]) else {
                throw NetworkError.invalidInput("Invalid CIDR format")
            }
            let ipStr = String(components[0])
            let ip = try IPv4Address(string: ipStr)
            
            if mode == .equal {
                guard let num = Int(numberOfSubnets), num > 0 else {
                    throw NetworkError.invalidInput("Invalid number of subnets")
                }
                results = try SubnettingCalculator.divideEqually(network: ip, prefixLength: prefix, numberOfSubnets: num)
            } else {
                var reqs: [(name: String, hosts: Int)] = []
                for r in vlsmRequirements {
                    if let h = Int(r.hosts) {
                        let name = r.name.isEmpty ? "Subnet \(r.id)" : r.name
                        reqs.append((name: name, hosts: h))
                    }
                }
                results = try SubnettingCalculator.divideVLSM(network: ip, prefixLength: prefix, requirements: reqs)
            }
            HistoryService.shared.add(entry: HistoryEntry(id: UUID(), date: Date(), type: "Subnetting", input: networkInput, summary: "\(results.count) subnets"))
        } catch {
            if let netErr = error as? NetworkError {
                errorMessage = netErr.localizedDescription
            } else {
                errorMessage = error.localizedDescription
            }
        }
    }
    
    func addRequirement() {
        vlsmRequirements.append(VLSMRequirementItem(name: "", hosts: ""))
    }
    
    func removeRequirement(id: UUID) {
        vlsmRequirements.removeAll { $0.id == id }
    }
    
    func clear() {
        networkInput = ""
        numberOfSubnets = ""
        vlsmRequirements = []
        results = []
        errorMessage = nil
    }
    
    func resultsAsText() -> String {
        return results.map { "\($0.name): \($0.networkAddress.description)/\($0.prefixLength)" }.joined(separator: "\n")
    }
    
    func resultsAsCSV() -> String {
        var csv = "Name,Network,Prefix,Mask,First Host,Last Host,Total,Usable,Requested\n"
        for r in results {
            csv += "\(r.name),\(r.networkAddress.description),\(r.prefixLength),\(r.subnetMask.description),\(r.firstUsableHost?.description ?? ""),\(r.lastUsableHost?.description ?? ""),\(r.totalAddresses),\(r.usableHosts),\(r.requestedHosts ?? 0)\n"
        }
        return csv
    }
}

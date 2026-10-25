import SwiftUI
import NetworkCalcKit

class ToolsViewModel: ObservableObject {
    @Published var checkIP: String = ""
    @Published var checkSubnet: String = ""
    @Published var checkResult: Bool?
    @Published var checkError: String?
    
    @Published var converterInput: String = ""
    @Published var converterCIDR: String?
    @Published var converterMask: String?
    @Published var converterWildcard: String?
    @Published var converterError: String?
    
    // DNS Lookup
    @Published var dnsQuery: String = ""
    @Published var dnsResult: DNSLookupResult?
    @Published var isResolvingDNS: Bool = false
    @Published var dnsError: String?
    
    // Ping Sweep
    @Published var pingTarget: String = ""
    @Published var pingResults: [PingHostResult] = []
    @Published var isScanning: Bool = false
    @Published var scanProgress: Double = 0.0
    @Published var pingError: String?
    
    private var scanTask: Task<Void, Never>?
    private let diagService = NetworkDiagnosticService.shared
    
    func checkIPInSubnet() {
        checkError = nil
        do {
            let ip = try IPv4Address(string: checkIP)
            let components = checkSubnet.split(separator: "/")
            guard components.count == 2, let prefix = Int(components[1]) else {
                throw NetworkError.invalidInput("Invalid CIDR format")
            }
            let net = try IPv4Address(string: String(components[0]))
            
            checkResult = SubnetTools.isIPInSubnet(ip: ip, network: net, prefixLength: prefix)
        } catch {
            if let netErr = error as? NetworkError {
                checkError = netErr.localizedDescription
            } else {
                checkError = error.localizedDescription
            }
        }
    }
    
    func convert() {
        converterError = nil
        do {
            if let p = Int(converterInput), p >= 0 && p <= 32 {
                converterCIDR = String(p)
                let mask = try SubnetTools.cidrToSubnetMask(prefixLength: p)
                converterMask = mask.description
                converterWildcard = SubnetTools.subnetMaskToWildcard(mask: mask).description
            } else if converterInput.contains(".") {
                let addr = try IPv4Address(string: converterInput)
                if addr.binaryString.contains("01") {
                    let mask = SubnetTools.wildcardToSubnetMask(wildcard: addr)
                    converterWildcard = addr.description
                    converterMask = mask.description
                    converterCIDR = String(try SubnetTools.subnetMaskToCIDR(mask: mask))
                } else {
                    converterMask = addr.description
                    converterCIDR = String(try SubnetTools.subnetMaskToCIDR(mask: addr))
                    converterWildcard = SubnetTools.subnetMaskToWildcard(mask: addr).description
                }
            } else {
                throw NetworkError.invalidInput("Invalid input format")
            }
        } catch {
            if let netErr = error as? NetworkError {
                converterError = netErr.localizedDescription
            } else {
                converterError = error.localizedDescription
            }
        }
    }
    
    func performDNSLookup() {
        dnsError = nil
        dnsResult = nil
        guard !dnsQuery.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        
        isResolvingDNS = true
        Task { @MainActor in
            do {
                let res = try await diagService.resolveDNS(query: self.dnsQuery)
                self.dnsResult = res
            } catch {
                self.dnsError = error.localizedDescription
            }
            self.isResolvingDNS = false
        }
    }
    
    func startPingSweep() {
        pingError = nil
        pingResults = []
        scanProgress = 0.0
        
        let target = pingTarget.trimmingCharacters(in: .whitespaces)
        guard !target.isEmpty else { return }
        
        var ipsToPing: [String] = []
        
        if target.contains("/") {
            // Subnet sweep
            do {
                let res = try IPv4Calculator.calculate(input: target)
                guard res.prefixLength >= 23 else {
                    pingError = "Subnet too large for sweep (max /23 or 512 hosts)."
                    return
                }
                
                if let first = res.firstUsableHost, let last = res.lastUsableHost {
                    var current = first.rawValue
                    let end = last.rawValue
                    while current <= end {
                        ipsToPing.append(IPv4Address(rawValue: current).description)
                        current += 1
                    }
                }
            } catch {
                pingError = error.localizedDescription
                return
            }
        } else {
            // Single IP or Hostname
            ipsToPing = [target]
        }
        
        guard !ipsToPing.isEmpty else {
            pingError = "No IP addresses to ping."
            return
        }
        
        isScanning = true
        let totalCount = ipsToPing.count
        
        scanTask = Task { @MainActor in
            var completed = 0
            
            // Sweep with controlled concurrency
            await withTaskGroup(of: PingHostResult.self) { group in
                var iterator = ipsToPing.makeIterator()
                let maxConcurrent = 15
                
                // Seed initial batch
                for _ in 0..<maxConcurrent {
                    if let ip = iterator.next() {
                        group.addTask {
                            await self.diagService.ping(ip: ip)
                        }
                    }
                }
                
                // Process results and feed remaining
                for await result in group {
                    if Task.isCancelled { break }
                    
                    self.pingResults.append(result)
                    completed += 1
                    self.scanProgress = Double(completed) / Double(totalCount)
                    
                    if let nextIP = iterator.next() {
                        group.addTask {
                            await self.diagService.ping(ip: nextIP)
                        }
                    }
                }
            }
            
            // Sort reachable first, then by IP
            self.pingResults.sort {
                if $0.isReachable != $1.isReachable {
                    return $0.isReachable && !$1.isReachable
                }
                return $0.ip < $1.ip
            }
            
            self.isScanning = false
        }
    }
    
    func cancelScan() {
        scanTask?.cancel()
        scanTask = nil
        isScanning = false
    }
    
    func clear() {
        checkIP = ""
        checkSubnet = ""
        checkResult = nil
        checkError = nil
        
        converterInput = ""
        converterCIDR = nil
        converterMask = nil
        converterWildcard = nil
        converterError = nil
        
        dnsQuery = ""
        dnsResult = nil
        dnsError = nil
        
        cancelScan()
        pingTarget = ""
        pingResults = []
        pingError = nil
        scanProgress = 0.0
    }
}

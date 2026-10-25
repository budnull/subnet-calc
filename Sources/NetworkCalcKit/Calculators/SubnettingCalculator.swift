// Calculators/SubnettingCalculator.swift
// NetworkCalcKit

import Foundation

public struct SubnettingCalculator: Sendable {
    
    /// Divide a network into N equal subnets
    public static func divideEqually(network: IPv4Address, prefixLength: Int, numberOfSubnets: Int) throws -> [SubnetAllocation] {
        guard numberOfSubnets > 0 else { throw NetworkError.invalidInput("Number of subnets must be > 0") }
        
        let additionalBits = Int(ceil(log2(Double(numberOfSubnets))))
        let newPrefix = prefixLength + additionalBits
        
        guard newPrefix <= 32 else {
            throw NetworkError.subnetsExceedSpace(requested: numberOfSubnets, maxPossible: 1 << (32 - prefixLength))
        }
        
        let actualSubnets = 1 << additionalBits
        let subnetSize = newPrefix == 32 ? 1 : (UInt32(1) << (32 - newPrefix))
        var allocations: [SubnetAllocation] = []
        
        for i in 0..<actualSubnets {
            let netRaw = network.rawValue + UInt32(i) * subnetSize
            let ip = IPv4Address(rawValue: netRaw)
            let result = try IPv4Calculator.calculate(ip: ip, prefixLength: newPrefix)
            
            let alloc = SubnetAllocation(
                name: "Subnet \(i + 1)",
                networkAddress: result.networkAddress,
                broadcastAddress: result.broadcastAddress,
                prefixLength: result.prefixLength,
                subnetMask: result.subnetMask,
                firstUsableHost: result.firstUsableHost,
                lastUsableHost: result.lastUsableHost,
                totalAddresses: result.totalAddresses,
                usableHosts: result.usableHosts,
                requestedHosts: nil
            )
            allocations.append(alloc)
            
            // Limit to requested number of subnets if it's less than actual power of 2 subnets generated? 
            // Often we return all generated subnets. The instructions say "for i in 0..<actualSubnets" implicitly if we allocate the whole space.
            if i + 1 == numberOfSubnets { break }
        }
        
        return allocations
    }
    
    /// VLSM allocation: allocate subnets for varying host requirements
    public static func divideVLSM(network: IPv4Address, prefixLength: Int, requirements: [(name: String, hosts: Int)]) throws -> [SubnetAllocation] {
        let sortedReqs = requirements.sorted { $0.hosts > $1.hosts }
        var allocations: [SubnetAllocation] = []
        var currentRaw = network.rawValue
        
        // Handle /0 max raw to prevent overflow
        let maxRaw: UInt32 = prefixLength == 0 ? UInt32.max : network.rawValue + (~UInt32(0) >> prefixLength)
        
        for req in sortedReqs {
            let neededSize = req.hosts + 2
            let additionalBits = Int(ceil(log2(Double(neededSize))))
            let prefix = 32 - additionalBits
            
            guard prefix <= 32 && prefix >= prefixLength else {
                throw NetworkError.invalidInput("Cannot satisfy requirement: \(req.name)")
            }
            
            let size = prefix == 32 ? 1 : UInt32(1) << additionalBits
            
            if currentRaw % size != 0 {
                currentRaw = ((currentRaw / size) + 1) * size
            }
            
            // Check overflow
            let (endRaw, overflow) = currentRaw.addingReportingOverflow(size - 1)
            if overflow || endRaw > maxRaw {
                throw NetworkError.subnetsExceedSpace(requested: req.hosts, maxPossible: 0)
            }
            
            let ip = IPv4Address(rawValue: currentRaw)
            let result = try IPv4Calculator.calculate(ip: ip, prefixLength: prefix)
            
            let alloc = SubnetAllocation(
                name: req.name,
                networkAddress: result.networkAddress,
                broadcastAddress: result.broadcastAddress,
                prefixLength: result.prefixLength,
                subnetMask: result.subnetMask,
                firstUsableHost: result.firstUsableHost,
                lastUsableHost: result.lastUsableHost,
                totalAddresses: result.totalAddresses,
                usableHosts: result.usableHosts,
                requestedHosts: req.hosts
            )
            allocations.append(alloc)
            
            currentRaw += size
        }
        
        return allocations
    }
}

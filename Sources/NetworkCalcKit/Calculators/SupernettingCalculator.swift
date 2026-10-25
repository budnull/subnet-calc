// Calculators/SupernettingCalculator.swift
// NetworkCalcKit

import Foundation

public struct SupernettingCalculator: Sendable {
    
    /// Aggregate multiple networks into a summary route
    public static func aggregate(networks: [(IPv4Address, Int)]) throws -> (network: IPv4Address, prefixLength: Int) {
        guard !networks.isEmpty else { throw NetworkError.invalidInput("Empty networks list") }
        
        var minRaw = UInt32.max
        var maxBroadcastRaw = UInt32.min
        
        for (ip, prefix) in networks {
            let res = try IPv4Calculator.calculate(ip: ip, prefixLength: prefix)
            if res.networkAddress.rawValue != ip.rawValue {
                throw NetworkError.hostBitsSet(ip: ip.description, correctedNetwork: res.networkAddress.description)
            }
            if res.networkAddress.rawValue < minRaw { minRaw = res.networkAddress.rawValue }
            if res.broadcastAddress.rawValue > maxBroadcastRaw { maxBroadcastRaw = res.broadcastAddress.rawValue }
        }
        
        let xored = minRaw ^ maxBroadcastRaw
        let diffBits = 32 - xored.leadingZeroBitCount
        let commonPrefix = 32 - diffBits
        
        let mask = commonPrefix == 0 ? 0 : (~UInt32(0) << (32 - commonPrefix))
        let supernetRaw = minRaw & mask
        
        return (network: IPv4Address(rawValue: supernetRaw), prefixLength: commonPrefix)
    }
}

// Calculators/IPv4Calculator.swift
// NetworkCalcKit

import Foundation

public struct IPv4Calculator: Sendable {
    
    /// Calculate subnet info from IP and prefix length
    public static func calculate(ip: IPv4Address, prefixLength: Int) throws -> IPv4SubnetResult {
        guard (0...32).contains(prefixLength) else {
            throw NetworkError.invalidCIDRPrefix(prefixLength)
        }
        
        let maskRaw: UInt32 = prefixLength == 0 ? 0 : (~UInt32(0) << (32 - prefixLength))
        let wildcardRaw: UInt32 = ~maskRaw
        let networkRaw = ip.rawValue & maskRaw
        let broadcastRaw = networkRaw | wildcardRaw
        
        let totalAddresses = prefixLength == 0 ? (UInt64(1) << 32) : UInt64(1) << (32 - prefixLength)
        
        var usableHosts: UInt64 = 0
        var firstUsableHost: IPv4Address? = nil
        var lastUsableHost: IPv4Address? = nil
        
        if prefixLength == 32 {
            usableHosts = 0
        } else if prefixLength == 31 {
            usableHosts = 2
            firstUsableHost = IPv4Address(rawValue: networkRaw)
            lastUsableHost = IPv4Address(rawValue: broadcastRaw)
        } else {
            usableHosts = totalAddresses - 2
            firstUsableHost = IPv4Address(rawValue: networkRaw + 1)
            lastUsableHost = IPv4Address(rawValue: broadcastRaw - 1)
        }
        
        let binStr = ip.rawValue.binaryStringPadded
        let networkBits = String(binStr.prefix(prefixLength))
        let hostBits = String(binStr.suffix(32 - prefixLength))
        
        let binHighlight = (network: networkBits, host: hostBits)
        
        return IPv4SubnetResult(
            inputIP: ip,
            prefixLength: prefixLength,
            networkAddress: IPv4Address(rawValue: networkRaw),
            broadcastAddress: IPv4Address(rawValue: broadcastRaw),
            subnetMask: IPv4Address(rawValue: maskRaw),
            wildcardMask: IPv4Address(rawValue: wildcardRaw),
            firstUsableHost: firstUsableHost,
            lastUsableHost: lastUsableHost,
            totalAddresses: totalAddresses,
            usableHosts: usableHosts,
            addressClass: ip.addressClass,
            addressTypes: ip.addressTypes,
            networkBits: networkBits,
            hostBits: hostBits,
            binaryWithHighlight: binHighlight
        )
    }
    
    /// Parse input string like "192.168.1.10/24" or "192.168.1.10 255.255.255.0"
    public static func calculate(input: String) throws -> IPv4SubnetResult {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.contains("/") {
            let parts = trimmed.split(separator: "/")
            guard parts.count == 2, let prefix = Int(parts[1]) else {
                throw NetworkError.invalidInput(input)
            }
            let ip = try IPv4Address(string: String(parts[0]))
            return try calculate(ip: ip, prefixLength: prefix)
        } else if trimmed.contains(" ") {
            let parts = trimmed.split(separator: " ", omittingEmptySubsequences: true)
            guard parts.count == 2 else { throw NetworkError.invalidInput(input) }
            let ip = try IPv4Address(string: String(parts[0]))
            let mask = try IPv4Address(string: String(parts[1]))
            let prefix = try SubnetTools.subnetMaskToCIDR(mask: mask)
            return try calculate(ip: ip, prefixLength: prefix)
        } else {
            throw NetworkError.invalidInput(input)
        }
    }
}

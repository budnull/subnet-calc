// Calculators/SubnetTools.swift
// NetworkCalcKit

public struct SubnetTools: Sendable {
    
    /// Check if an IP belongs to a given subnet
    public static func isIPInSubnet(ip: IPv4Address, network: IPv4Address, prefixLength: Int) -> Bool {
        let mask = prefixLength == 0 ? 0 : (~UInt32(0) << (32 - prefixLength))
        return (ip.rawValue & mask) == (network.rawValue & mask)
    }
    
    /// Convert CIDR prefix length to subnet mask
    public static func cidrToSubnetMask(prefixLength: Int) throws -> IPv4Address {
        guard (0...32).contains(prefixLength) else { throw NetworkError.invalidCIDRPrefix(prefixLength) }
        let maskRaw = prefixLength == 0 ? 0 : (~UInt32(0) << (32 - prefixLength))
        return IPv4Address(rawValue: maskRaw)
    }
    
    /// Convert subnet mask to CIDR prefix length
    public static func subnetMaskToCIDR(mask: IPv4Address) throws -> Int {
        let ones = mask.rawValue.nonzeroBitCount
        let expectedMask = ones == 0 ? 0 : (~UInt32(0) << (32 - ones))
        guard mask.rawValue == expectedMask else {
            throw NetworkError.invalidSubnetMask(mask.description)
        }
        return ones
    }
    
    /// Convert subnet mask to wildcard mask
    public static func subnetMaskToWildcard(mask: IPv4Address) -> IPv4Address {
        return IPv4Address(rawValue: ~mask.rawValue)
    }
    
    /// Convert wildcard mask to subnet mask
    public static func wildcardToSubnetMask(wildcard: IPv4Address) -> IPv4Address {
        return IPv4Address(rawValue: ~wildcard.rawValue)
    }
}

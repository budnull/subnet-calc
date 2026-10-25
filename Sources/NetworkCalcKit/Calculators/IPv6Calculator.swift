// Calculators/IPv6Calculator.swift
// NetworkCalcKit

import Foundation

public struct IPv6Calculator: Sendable {
    
    public static func calculate(address: IPv6Address, prefixLength: Int) throws -> IPv6SubnetResult {
        guard (0...128).contains(prefixLength) else {
            throw NetworkError.invalidCIDRPrefix(prefixLength)
        }
        
        var netGroups = [UInt16](repeating: 0, count: 8)
        var firstGroups = [UInt16](repeating: 0, count: 8)
        var lastGroups = [UInt16](repeating: 0, count: 8)
        
        for i in 0..<8 {
            let bitStart = i * 16
            let bitEnd = bitStart + 15
            
            if prefixLength <= bitStart {
                netGroups[i] = 0
                firstGroups[i] = 0
                lastGroups[i] = 0xFFFF
            } else if prefixLength > bitEnd {
                netGroups[i] = address.groups[i]
                firstGroups[i] = address.groups[i]
                lastGroups[i] = address.groups[i]
            } else {
                let bitsInGroup = prefixLength - bitStart
                let mask = UInt16(0xFFFF) << (16 - bitsInGroup)
                netGroups[i] = address.groups[i] & mask
                firstGroups[i] = netGroups[i]
                lastGroups[i] = netGroups[i] | ~mask
            }
        }
        
        let total = powerOfTwo(exponent: 128 - prefixLength)
        
        return IPv6SubnetResult(
            inputAddress: address,
            prefixLength: prefixLength,
            networkPrefix: try IPv6Address(groups: netGroups),
            firstAddress: try IPv6Address(groups: firstGroups),
            lastAddress: try IPv6Address(groups: lastGroups),
            totalAddresses: total
        )
    }
    
    public static func calculate(input: String) throws -> IPv6SubnetResult {
        let parts = input.split(separator: "/")
        guard parts.count == 2, let prefix = Int(parts[1]) else {
            throw NetworkError.invalidInput(input)
        }
        let addr = try IPv6Address(string: String(parts[0]))
        return try calculate(address: addr, prefixLength: prefix)
    }
    
    private static func powerOfTwo(exponent: Int) -> String {
        if exponent == 0 { return "1" }
        var result = [1]
        for _ in 0..<exponent {
            var carry = 0
            for i in 0..<result.count {
                let val = result[i] * 2 + carry
                result[i] = val % 10
                carry = val / 10
            }
            if carry > 0 {
                result.append(carry)
            }
        }
        return result.reversed().map { String($0) }.joined()
    }
}

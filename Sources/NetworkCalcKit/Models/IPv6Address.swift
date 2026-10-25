// Models/IPv6Address.swift
// NetworkCalcKit

import Foundation

public struct IPv6Address: Equatable, Hashable, Sendable, CustomStringConvertible, Codable {
    public let groups: [UInt16]
    
    public init(groups: [UInt16]) throws {
        guard groups.count == 8 else {
            throw NetworkError.invalidIPv6Address("Must have exactly 8 groups")
        }
        self.groups = groups
    }
    
    public init(string: String) throws {
        var parseStr = string.trimmingCharacters(in: .whitespacesAndNewlines)
        if parseStr.hasPrefix("::") { parseStr = "0" + parseStr }
        if parseStr.hasSuffix("::") { parseStr = parseStr + "0" }
        
        let parts = parseStr.components(separatedBy: "::")
        if parts.count > 2 { throw NetworkError.invalidIPv6Address(string) }
        
        var parsedGroups: [UInt16] = []
        
        if parts.count == 1 {
            let segs = parts[0].components(separatedBy: ":")
            if segs.count != 8 { throw NetworkError.invalidIPv6Address(string) }
            for seg in segs {
                guard let val = UInt16(seg, radix: 16) else { throw NetworkError.invalidIPv6Address(string) }
                parsedGroups.append(val)
            }
        } else {
            let leftSegs = parts[0].isEmpty ? [] : parts[0].components(separatedBy: ":")
            let rightSegs = parts[1].isEmpty ? [] : parts[1].components(separatedBy: ":")
            
            let missing = 8 - (leftSegs.count + rightSegs.count)
            if missing < 0 { throw NetworkError.invalidIPv6Address(string) }
            
            for seg in leftSegs {
                guard let val = UInt16(seg, radix: 16) else { throw NetworkError.invalidIPv6Address(string) }
                parsedGroups.append(val)
            }
            for _ in 0..<missing {
                parsedGroups.append(0)
            }
            for seg in rightSegs {
                guard let val = UInt16(seg, radix: 16) else { throw NetworkError.invalidIPv6Address(string) }
                parsedGroups.append(val)
            }
        }
        self.groups = parsedGroups
    }
    
    public var expandedString: String {
        return groups.map { String(format: "%04x", $0) }.joined(separator: ":")
    }
    
    public var compressedString: String {
        var maxZeroStart = -1
        var maxZeroLength = 0
        var currentZeroStart = -1
        var currentZeroLength = 0
        
        for i in 0..<8 {
            if groups[i] == 0 {
                if currentZeroStart == -1 {
                    currentZeroStart = i
                }
                currentZeroLength += 1
            } else {
                if currentZeroLength > maxZeroLength {
                    maxZeroLength = currentZeroLength
                    maxZeroStart = currentZeroStart
                }
                currentZeroStart = -1
                currentZeroLength = 0
            }
        }
        
        if currentZeroLength > maxZeroLength {
            maxZeroLength = currentZeroLength
            maxZeroStart = currentZeroStart
        }
        
        if maxZeroLength > 1 {
            let before = groups[0..<maxZeroStart].map { String(format: "%x", $0) }
            let after = groups[(maxZeroStart + maxZeroLength)..<8].map { String(format: "%x", $0) }
            
            let beforeStr = before.joined(separator: ":")
            let afterStr = after.joined(separator: ":")
            
            return "\(beforeStr)::\(afterStr)"
        } else {
            return groups.map { String(format: "%x", $0) }.joined(separator: ":")
        }
    }
    
    public var description: String {
        return compressedString
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let str = try container.decode(String.self)
        try self.init(string: str)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(expandedString)
    }
}

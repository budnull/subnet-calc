// Models/IPv4Address.swift
// NetworkCalcKit

import Foundation

public struct IPv4Address: Equatable, Hashable, Sendable, CustomStringConvertible, Codable {
    public let rawValue: UInt32
    
    public var octets: (UInt8, UInt8, UInt8, UInt8) {
        return (
            UInt8((rawValue >> 24) & 0xFF),
            UInt8((rawValue >> 16) & 0xFF),
            UInt8((rawValue >> 8) & 0xFF),
            UInt8(rawValue & 0xFF)
        )
    }
    
    public init(rawValue: UInt32) {
        self.rawValue = rawValue
    }
    
    public init(_ a: UInt8, _ b: UInt8, _ c: UInt8, _ d: UInt8) {
        self.rawValue = (UInt32(a) << 24) | (UInt32(b) << 16) | (UInt32(c) << 8) | UInt32(d)
    }
    
    public init(string: String) throws {
        let parts = string.split(separator: ".")
        guard parts.count == 4 else {
            throw NetworkError.invalidIPv4Address(string)
        }
        
        var bytes: [UInt8] = []
        for part in parts {
            guard let val = UInt8(part) else {
                throw NetworkError.invalidIPv4Address(string)
            }
            bytes.append(val)
        }
        
        self.init(bytes[0], bytes[1], bytes[2], bytes[3])
    }
    
    public var description: String {
        let o = octets
        return "\(o.0).\(o.1).\(o.2).\(o.3)"
    }
    
    public var binaryString: String {
        return rawValue.dottedBinaryString
    }
    
    public var addressClass: AddressClass {
        let first = octets.0
        if first <= 127 { return .A }
        if first <= 191 { return .B }
        if first <= 223 { return .C }
        if first <= 239 { return .D }
        return .E
    }
    
    public var addressTypes: [AddressType] {
        var types: [AddressType] = []
        let o = octets
        let first = o.0
        let second = o.1
        
        if first == 10 {
            types.append(.private)
        } else if first == 172 && (second >= 16 && second <= 31) {
            types.append(.private)
        } else if first == 192 && second == 168 {
            types.append(.private)
        } else if first == 127 {
            types.append(.loopback)
        } else if first == 169 && second == 254 {
            types.append(.linkLocal)
        } else if first >= 224 && first <= 239 {
            types.append(.multicast)
        } else if first >= 240 && rawValue != 0xFFFFFFFF {
            types.append(.reserved)
        } else if rawValue == 0xFFFFFFFF {
            types.append(.broadcast)
        } else if first == 0 {
            types.append(.currentNetwork)
        } else {
            types.append(.public)
        }
        
        return types
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let str = try container.decode(String.self)
        try self.init(string: str)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(description)
    }
}

// Extensions/String+Validation.swift
// NetworkCalcKit

import Foundation

extension String {
    /// Trim whitespace and validate as IPv4 address string
    public var isValidIPv4: Bool {
        let trimmed = self.trimmingCharacters(in: .whitespacesAndNewlines)
        let parts = trimmed.split(separator: ".")
        guard parts.count == 4 else { return false }
        for part in parts {
            guard let val = UInt8(part) else { return false }
            if String(val) != part { return false }
        }
        return true
    }
    
    /// Trim whitespace and validate as IPv6 address string  
    public var isValidIPv6: Bool {
        let trimmed = self.trimmingCharacters(in: .whitespacesAndNewlines)
        do {
            _ = try IPv6Address(string: trimmed)
            return true
        } catch {
            return false
        }
    }
    
    /// Check if string is valid CIDR notation (IP/prefix)
    public var isValidCIDR: Bool {
        let trimmed = self.trimmingCharacters(in: .whitespacesAndNewlines)
        let parts = trimmed.split(separator: "/")
        guard parts.count == 2 else { return false }
        
        let ipPart = String(parts[0])
        let prefixPart = String(parts[1])
        
        guard let prefix = Int(prefixPart) else { return false }
        
        if ipPart.isValidIPv4 {
            return prefix >= 0 && prefix <= 32
        } else if ipPart.isValidIPv6 {
            return prefix >= 0 && prefix <= 128
        }
        return false
    }
}

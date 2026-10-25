// Extensions/UInt32+Binary.swift
// NetworkCalcKit

import Foundation

extension UInt32 {
    /// Returns 32-character binary string with leading zeros
    public var binaryStringPadded: String {
        var str = String(self, radix: 2)
        while str.count < 32 {
            str = "0" + str
        }
        return str
    }
    
    /// Returns dotted binary string like "11000000.10101000.00000001.00000001"
    public var dottedBinaryString: String {
        let bin = binaryStringPadded
        let o1 = bin.prefix(8)
        let o2 = bin.dropFirst(8).prefix(8)
        let o3 = bin.dropFirst(16).prefix(8)
        let o4 = bin.suffix(8)
        return "\(o1).\(o2).\(o3).\(o4)"
    }
    
    /// Count leading ones
    public var leadingOnes: Int {
        return (~self).leadingZeroBitCount
    }
}

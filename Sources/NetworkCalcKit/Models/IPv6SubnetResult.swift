// Models/IPv6SubnetResult.swift
// NetworkCalcKit

public struct IPv6SubnetResult: Sendable {
    public let inputAddress: IPv6Address
    public let prefixLength: Int
    public let networkPrefix: IPv6Address
    public let firstAddress: IPv6Address
    public let lastAddress: IPv6Address
    public let totalAddresses: String
    
    public init(inputAddress: IPv6Address, prefixLength: Int, networkPrefix: IPv6Address, firstAddress: IPv6Address, lastAddress: IPv6Address, totalAddresses: String) {
        self.inputAddress = inputAddress
        self.prefixLength = prefixLength
        self.networkPrefix = networkPrefix
        self.firstAddress = firstAddress
        self.lastAddress = lastAddress
        self.totalAddresses = totalAddresses
    }
}

// Models/IPv4SubnetResult.swift
// NetworkCalcKit

public struct IPv4SubnetResult: Sendable {
    public let inputIP: IPv4Address
    public let prefixLength: Int
    public let networkAddress: IPv4Address
    public let broadcastAddress: IPv4Address
    public let subnetMask: IPv4Address
    public let wildcardMask: IPv4Address
    public let firstUsableHost: IPv4Address?
    public let lastUsableHost: IPv4Address?
    public let totalAddresses: UInt64
    public let usableHosts: UInt64
    public let addressClass: AddressClass
    public let addressTypes: [AddressType]
    public let networkBits: String
    public let hostBits: String
    public let binaryWithHighlight: (network: String, host: String)
    
    public init(inputIP: IPv4Address, prefixLength: Int, networkAddress: IPv4Address, broadcastAddress: IPv4Address, subnetMask: IPv4Address, wildcardMask: IPv4Address, firstUsableHost: IPv4Address?, lastUsableHost: IPv4Address?, totalAddresses: UInt64, usableHosts: UInt64, addressClass: AddressClass, addressTypes: [AddressType], networkBits: String, hostBits: String, binaryWithHighlight: (network: String, host: String)) {
        self.inputIP = inputIP
        self.prefixLength = prefixLength
        self.networkAddress = networkAddress
        self.broadcastAddress = broadcastAddress
        self.subnetMask = subnetMask
        self.wildcardMask = wildcardMask
        self.firstUsableHost = firstUsableHost
        self.lastUsableHost = lastUsableHost
        self.totalAddresses = totalAddresses
        self.usableHosts = usableHosts
        self.addressClass = addressClass
        self.addressTypes = addressTypes
        self.networkBits = networkBits
        self.hostBits = hostBits
        self.binaryWithHighlight = binaryWithHighlight
    }
}

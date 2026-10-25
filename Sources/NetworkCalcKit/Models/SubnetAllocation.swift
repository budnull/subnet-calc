// Models/SubnetAllocation.swift
// NetworkCalcKit

import Foundation

public struct SubnetAllocation: Identifiable, Sendable {
    public let id: UUID
    public let name: String
    public let networkAddress: IPv4Address
    public let broadcastAddress: IPv4Address
    public let prefixLength: Int
    public let subnetMask: IPv4Address
    public let firstUsableHost: IPv4Address?
    public let lastUsableHost: IPv4Address?
    public let totalAddresses: UInt64
    public let usableHosts: UInt64
    public let requestedHosts: Int?
    
    public init(name: String, networkAddress: IPv4Address, broadcastAddress: IPv4Address, prefixLength: Int, subnetMask: IPv4Address, firstUsableHost: IPv4Address?, lastUsableHost: IPv4Address?, totalAddresses: UInt64, usableHosts: UInt64, requestedHosts: Int?) {
        self.id = UUID()
        self.name = name
        self.networkAddress = networkAddress
        self.broadcastAddress = broadcastAddress
        self.prefixLength = prefixLength
        self.subnetMask = subnetMask
        self.firstUsableHost = firstUsableHost
        self.lastUsableHost = lastUsableHost
        self.totalAddresses = totalAddresses
        self.usableHosts = usableHosts
        self.requestedHosts = requestedHosts
    }
}

// Models/AddressType.swift
// NetworkCalcKit

public enum AddressType: String, CaseIterable, Sendable {
    case `public` = "Public"
    case `private` = "Private"
    case loopback = "Loopback"
    case linkLocal = "Link-Local"
    case multicast = "Multicast"
    case reserved = "Reserved"
    case broadcast = "Broadcast"
    case currentNetwork = "Current Network"
    
    public var localizedName: String {
        return self.rawValue
    }
    
    public var description: String {
        switch self {
        case .public: return "Publicly routable IP address."
        case .private: return "Private IP address (RFC 1918), not publicly routable."
        case .loopback: return "Loopback address used for testing local network interfaces."
        case .linkLocal: return "Link-local address (APIPA), used when no DHCP server is available."
        case .multicast: return "Multicast address used for one-to-many communication."
        case .reserved: return "Reserved for future use or special purposes."
        case .broadcast: return "Broadcast address used to send data to all hosts on a network."
        case .currentNetwork: return "Refers to the current network ('this' network)."
        }
    }
}

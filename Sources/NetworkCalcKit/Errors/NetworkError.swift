// Errors/NetworkError.swift
// NetworkCalcKit

import Foundation

public enum NetworkError: Error, LocalizedError, Equatable, Sendable {
    case invalidIPv4Address(String)
    case invalidIPv6Address(String)
    case invalidCIDRPrefix(Int)
    case invalidSubnetMask(String)
    case hostBitsSet(ip: String, correctedNetwork: String)
    case networksNotContiguous
    case networksNotAligned
    case insufficientAddressSpace(required: UInt64, available: UInt64)
    case invalidInput(String)
    case subnetsExceedSpace(requested: Int, maxPossible: Int)
    case prefixLengthOutOfRange(Int)
    
    public var errorDescription: String? {
        let isItalian = Locale.current.language.languageCode?.identifier == "it" || Locale.current.identifier.hasPrefix("it")
        if isItalian {
            switch self {
            case .invalidIPv4Address(let ip): return "Indirizzo IPv4 non valido: \(ip)"
            case .invalidIPv6Address(let ip): return "Indirizzo IPv6 non valido: \(ip)"
            case .invalidCIDRPrefix(let prefix): return "Lunghezza prefisso CIDR non valida: \(prefix). Deve essere tra 0 e 32 (IPv4) o 0 e 128 (IPv6)."
            case .invalidSubnetMask(let mask): return "Maschera di sottorete non valida: \(mask)"
            case .hostBitsSet(let ip, let corrected): return "Bit di host impostati nell'indirizzo di rete \(ip). Previsto \(corrected)."
            case .networksNotContiguous: return "Le reti non sono contigue."
            case .networksNotAligned: return "Le reti non sono allineate per il supernetting."
            case .insufficientAddressSpace(let req, let avail): return "Spazio indirizzi insufficiente. Richiesto: \(req), Disponibile: \(avail)."
            case .invalidInput(let input): return "Input non valido: \(input)"
            case .subnetsExceedSpace(let req, let max): return "Le sottoreti richieste (\(req)) superano il massimo possibile (\(max))."
            case .prefixLengthOutOfRange(let prefix): return "Lunghezza del prefisso fuori intervallo: \(prefix)"
            }
        } else {
            switch self {
            case .invalidIPv4Address(let ip): return "Invalid IPv4 address: \(ip)"
            case .invalidIPv6Address(let ip): return "Invalid IPv6 address: \(ip)"
            case .invalidCIDRPrefix(let prefix): return "Invalid CIDR prefix length: \(prefix). Must be between 0 and 32 for IPv4, or 0 and 128 for IPv6."
            case .invalidSubnetMask(let mask): return "Invalid subnet mask: \(mask)"
            case .hostBitsSet(let ip, let corrected): return "Host bits are set in network address \(ip). Expected \(corrected)."
            case .networksNotContiguous: return "Networks are not contiguous."
            case .networksNotAligned: return "Networks are not aligned for supernetting."
            case .insufficientAddressSpace(let req, let avail): return "Insufficient address space. Required: \(req), Available: \(avail)."
            case .invalidInput(let input): return "Invalid input: \(input)"
            case .subnetsExceedSpace(let req, let max): return "Requested subnets (\(req)) exceed maximum possible subnets (\(max)) for the given space."
            case .prefixLengthOutOfRange(let prefix): return "Prefix length out of range: \(prefix)"
            }
        }
    }
}

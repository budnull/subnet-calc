// Models/AddressClass.swift
// NetworkCalcKit

public enum AddressClass: String, CaseIterable, Sendable {
    case A, B, C, D, E
    
    public var defaultPrefixLength: Int? {
        switch self {
        case .A: return 8
        case .B: return 16
        case .C: return 24
        case .D, .E: return nil
        }
    }
}

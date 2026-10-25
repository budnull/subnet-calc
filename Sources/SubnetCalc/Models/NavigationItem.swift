import Foundation
import SwiftUI

enum NavigationItem: String, CaseIterable, Identifiable {
    case ipv4 = "IPv4"
    case ipv6 = "IPv6"
    case subnetting = "Subnetting"
    case supernetting = "Supernetting"
    case tools = "Tools"
    case history = "History"
    case help = "Help"
    
    var id: Self { self }
    
    var icon: String {
        switch self {
        case .ipv4: return "4.circle"
        case .ipv6: return "6.circle"
        case .subnetting: return "rectangle.split.3x1"
        case .supernetting: return "arrow.triangle.merge"
        case .tools: return "wrench"
        case .history: return "clock"
        case .help: return "questionmark.circle"
        }
    }
    
    var localizedName: LocalizedStringKey {
        LocalizedStringKey(rawValue)
    }
}

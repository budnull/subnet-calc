import SwiftUI

struct ContentView: View {
    @State private var selectedItem: NavigationItem? = .ipv4
    
    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
        return "v\(version)"
    }
    
    var body: some View {
        NavigationSplitView {
            SidebarView(selectedItem: $selectedItem)
        } detail: {
            ZStack(alignment: .topTrailing) {
                Group {
                    switch selectedItem {
                    case .ipv4:
                        IPv4View()
                    case .ipv6:
                        IPv6View()
                    case .subnetting:
                        SubnettingView()
                    case .supernetting:
                        SupernettingView()
                    case .tools:
                        ToolsView()
                    case .history:
                        HistoryView()
                    case .help:
                        HelpView()
                    case .none:
                        Text("Select an item")
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                // Version badge in the top right corner
                Text(appVersion)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(NSColor.controlBackgroundColor))
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                    )
                    .cornerRadius(6)
                    .padding(.trailing, 20)
                    .padding(.top, 24)
            }
        }
    }
}

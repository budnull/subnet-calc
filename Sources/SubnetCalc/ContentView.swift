import SwiftUI

struct ContentView: View {
    @State private var selectedItem: NavigationItem? = .ipv4
    
    var body: some View {
        NavigationSplitView {
            SidebarView(selectedItem: $selectedItem)
        } detail: {
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
    }
}

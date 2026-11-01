import SwiftUI

struct SidebarView: View {
    @Binding var selectedItem: NavigationItem?
    
    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
        return "v\(version)"
    }
    
    var body: some View {
        VStack(spacing: 0) {
            List(NavigationItem.allCases, id: \.self, selection: $selectedItem) { item in
                NavigationLink(value: item) {
                    Label(item.localizedName, systemImage: item.icon)
                }
                .tag(item)
            }
            .listStyle(.sidebar)
            
            Divider()
            
            HStack {
                Text("SubnetCalc")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                Spacer()
                Text(appVersion)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.secondary.opacity(0.12))
                    .cornerRadius(4)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
        }
        .navigationTitle("SubnetCalc")
    }
}

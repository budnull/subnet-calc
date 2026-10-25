import SwiftUI

struct SidebarView: View {
    @Binding var selectedItem: NavigationItem?
    
    var body: some View {
        List(NavigationItem.allCases, id: \.self, selection: $selectedItem) { item in
            NavigationLink(value: item) {
                Label(item.localizedName, systemImage: item.icon)
            }
            .tag(item)
        }
        .listStyle(.sidebar)
        .navigationTitle("SubnetCalc")
    }
}

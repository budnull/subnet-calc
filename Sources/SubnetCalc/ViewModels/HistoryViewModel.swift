import SwiftUI

class HistoryViewModel: ObservableObject {
    @Published var entries: [HistoryEntry] = []
    private let service = HistoryService.shared
    
    init() {
        load()
    }
    
    func load() {
        entries = service.entries
    }
    
    func clearHistory() {
        service.clear()
        load()
    }
}

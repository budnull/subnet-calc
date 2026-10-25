import Foundation

class HistoryService: ObservableObject {
    static let shared = HistoryService()
    
    @Published var entries: [HistoryEntry] = []
    
    private let defaultsKey = "HistoryEntries"
    private let maxEntries = 100
    
    private init() {
        load()
    }
    
    func add(entry: HistoryEntry) {
        entries.insert(entry, at: 0)
        if entries.count > maxEntries {
            entries.removeLast()
        }
        save()
    }
    
    func clear() {
        entries.removeAll()
        save()
    }
    
    private func save() {
        if let encoded = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(encoded, forKey: defaultsKey)
        }
    }
    
    private func load() {
        if let data = UserDefaults.standard.data(forKey: defaultsKey),
           let decoded = try? JSONDecoder().decode([HistoryEntry].self, from: data) {
            entries = decoded
        }
    }
}

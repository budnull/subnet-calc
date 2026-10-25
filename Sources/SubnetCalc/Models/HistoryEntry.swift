import Foundation

struct HistoryEntry: Identifiable, Codable {
    let id: UUID
    let date: Date
    let type: String
    let input: String
    let summary: String
}

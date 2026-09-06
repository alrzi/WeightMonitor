import Foundation

struct NoteSyncValue: Codable, Identifiable, Sendable, Equatable {
    let id: UUID
    let text: String
}

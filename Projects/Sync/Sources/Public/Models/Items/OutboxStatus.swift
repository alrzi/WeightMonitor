import Foundation

public enum OutboxStatus: String, Codable, CaseIterable, Sendable {
    case pending
    case sending
    case awaitingAcknowledgement
    case synced
    case failed
}

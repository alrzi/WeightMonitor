import Foundation

/// Подтверждение успешной обработки конкретного payload другим устройством.
public struct SyncAcknowledgement: Codable, Equatable, Sendable {
    /// Идентификатор подтверждённой попытки доставки.
    public let payloadID: UUID

    /// Создаёт подтверждение для payload с указанным идентификатором.
    public init(payloadID: UUID) {
        self.payloadID = payloadID
    }
}

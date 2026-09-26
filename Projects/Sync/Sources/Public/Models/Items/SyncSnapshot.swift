import Foundation

/// Полное известное устройству состояние синхронизируемых ресурсов.
public struct SyncSnapshot: Codable, Equatable, Sendable {
    /// Payload актуальных записей и сохранённых удалений всех ресурсов.
    public let payloads: [SyncPayload]

    /// Создаёт snapshot из подготовленного набора payload.
    public init(payloads: [SyncPayload]) {
        self.payloads = payloads
    }
}

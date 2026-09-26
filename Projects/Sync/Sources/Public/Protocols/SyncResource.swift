import Foundation

public protocol SyncResource: Sendable {
    var dataType: SyncDataType { get }

    /// Применяет payload, тип которого совпадает с `dataType` ресурса.
    ///
    /// - Returns: `true`, если локальные данные изменились; `false`, если payload
    ///   уже применён, устарел или не требует изменения локального состояния.
    /// - Throws: Ошибка декодирования, чтения или записи данных ресурса.
    func applyMatching(_ payload: SyncPayload) async throws -> Bool

    /// Создаёт payload для каждой актуальной записи ресурса.
    ///
    /// Snapshot включает как существующие записи, так и сохранённые удаления,
    /// необходимые другому устройству для восстановления итогового состояния.
    ///
    /// - Throws: Ошибка чтения или кодирования данных ресурса.
    func snapshotPayloads() async throws -> [SyncPayload]
}

public extension SyncResource {
    /// Проверяет тип payload и передаёт совпавший payload в реализацию ресурса.
    ///
    /// - Returns: `false`, если payload предназначен другому типу ресурса;
    ///   иначе возвращает результат `applyMatching(_:)`.
    /// - Throws: Ошибка, возникшая при применении совпавшего payload.
    func apply(_ payload: SyncPayload) async throws -> Bool {
        guard payload.dataType == dataType else {
            return false
        }

        return try await applyMatching(payload)
    }
}

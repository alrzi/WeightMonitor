import Foundation

/// Одно версионированное изменение синхронизируемой записи.
public struct SyncPayload: Codable, Equatable, Sendable {
    /// Уникальный идентификатор доставки, используемый для дедупликации и acknowledgement.
    public let id: UUID

    /// Стабильный идентификатор изменяемой доменной записи.
    public let recordID: UUID

    /// Тип ресурса, которому принадлежит запись.
    public let dataType: SyncDataType

    /// Версия изменения, используемая при разрешении конфликтов.
    public let version: SyncVersion

    /// Признак удаления записи вместо обновления её содержимого.
    public let isDeleted: Bool

    /// Закодированное содержимое записи; для удаления может быть пустым.
    public let data: Data

    /// Создаёт payload изменения или удаления записи.
    ///
    /// - Parameter id: Идентификатор доставки. При отсутствии создаётся новый UUID.
    public init(
        id: UUID = UUID(),
        recordID: UUID,
        dataType: SyncDataType,
        version: SyncVersion,
        isDeleted: Bool,
        data: Data
    ) {
        self.id = id
        self.recordID = recordID
        self.dataType = dataType
        self.version = version
        self.isDeleted = isDeleted
        self.data = data
    }
}

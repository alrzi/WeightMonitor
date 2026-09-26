/// Стабильный идентификатор типа данных, используемый для маршрутизации payload к ресурсу.
public struct SyncDataType: RawRepresentable, Codable, Hashable, Sendable {
    /// Значение, которое сохраняется в БД и передаётся между устройствами.
    public let rawValue: String

    /// Создаёт идентификатор типа данных из его стабильного строкового представления.
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}

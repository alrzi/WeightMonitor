import Foundation

/// Логическая версия изменения с детерминированным порядком между устройствами.
public struct SyncVersion: Codable, Equatable, Sendable {
    /// Физическое время изменения с точностью до миллисекунды.
    public let physicalTime: Date

    /// Счётчик изменений, созданных при одинаковом физическом времени.
    public let logicalCounter: UInt64

    /// Идентификатор устройства, используемый как финальный критерий сравнения.
    public let deviceID: UUID

    /// Создаёт версию, нормализуя физическое время до миллисекунд.
    public init(
        physicalTime: Date,
        logicalCounter: UInt64,
        deviceID: UUID
    ) {
        self.physicalTime = Date(
            timeIntervalSince1970: (
                physicalTime.timeIntervalSince1970 * 1_000
            )
            .rounded() / 1_000
        )
        self.logicalCounter = logicalCounter
        self.deviceID = deviceID
    }
}

extension SyncVersion: Comparable {
    /// Сравнивает версии по времени, логическому счётчику и идентификатору устройства.
    public static func < (lhs: Self, rhs: Self) -> Bool {
        if lhs.physicalTime != rhs.physicalTime {
            return lhs.physicalTime < rhs.physicalTime
        }

        if lhs.logicalCounter != rhs.logicalCounter {
            return lhs.logicalCounter < rhs.logicalCounter
        }

        return lhs.deviceID.uuidString < rhs.deviceID.uuidString
    }
}

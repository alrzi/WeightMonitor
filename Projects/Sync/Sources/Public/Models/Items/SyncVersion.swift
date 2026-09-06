import Foundation

public struct SyncVersion: Codable, Equatable, Sendable {
    public let physicalTime: Date
    public let logicalCounter: UInt64
    public let deviceID: UUID

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

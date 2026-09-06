import Foundation
import Sync

extension SyncMetadataDB {
    var version: SyncVersion {
        get throws {
            guard
                logicalCounter >= 0,
                let deviceID = UUID(uuidString: originDeviceID)
            else {
                throw OutboxDBMappingError.logicalCounterOverflow
            }

            return SyncVersion(
                physicalTime: physicalTime,
                logicalCounter: UInt64(logicalCounter),
                deviceID: deviceID
            )
        }
    }

    init(payload: SyncPayload) throws {
        guard payload.version.logicalCounter <= UInt64(Int64.max) else {
            throw OutboxDBMappingError.logicalCounterOverflow
        }

        self.init(
            dataType: payload.dataType.rawValue,
            recordID: payload.recordID.uuidString,
            physicalTime: payload.version.physicalTime,
            logicalCounter: Int64(payload.version.logicalCounter),
            originDeviceID: payload.version.deviceID.uuidString,
            isDeleted: payload.isDeleted
        )
    }
}

import Foundation
import Sync
@testable import SyncImplementation

actor PayloadApplierSpy: SyncResource {
    enum ApplyError: Error {
        case failed
    }

    let dataType = SyncDataType(rawValue: "weight")
    private(set) var appliedPayloadIDs: [UUID] = []
    private var failuresBeforeSuccess: Int

    init(failuresBeforeSuccess: Int = 0) {
        self.failuresBeforeSuccess = failuresBeforeSuccess
    }

    func applyMatching(_ payload: SyncPayload) throws -> Bool {
        appliedPayloadIDs.append(payload.id)

        guard failuresBeforeSuccess == 0 else {
            failuresBeforeSuccess -= 1
            throw ApplyError.failed
        }

        return true
    }

    func snapshotPayloads() -> [SyncPayload] {
        []
    }
}

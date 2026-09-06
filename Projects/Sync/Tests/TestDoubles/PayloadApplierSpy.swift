import Foundation
import Sync
@testable import SyncImplementation

actor PayloadApplierSpy: SyncResource {
    let dataType = SyncDataType(rawValue: "weight")
    private(set) var appliedPayloadIDs: [UUID] = []
    func apply(_ payload: SyncPayload) -> Bool {
        appliedPayloadIDs.append(payload.id); return true
    }

    func snapshotPayloads() -> [SyncPayload] {
        []
    }
}

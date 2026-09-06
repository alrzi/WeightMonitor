import Foundation
internal import GRDB
import Sync
import Testing
@testable import Data

@Suite
struct SyncStateStoreTests {
    @Test
    func test_createsStableDeviceIDAndPersistsVersion() async throws {
        // GIVEN
        let dbPool = try makeDatabasePool()
        let store = SyncStateStore(dbPool: dbPool)
        let version = SyncVersion(
            physicalTime: Date(timeIntervalSince1970: 1_000),
            logicalCounter: 1,
            deviceID: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
        )

        // WHEN
        let firstDeviceID = try await store.loadOrCreateDeviceID()
        let secondDeviceID = try await store.loadOrCreateDeviceID()
        try await store.save(version: version)
        let loadedVersion = try await store.loadVersion()

        // THEN
        #expect(firstDeviceID == secondDeviceID)
        #expect(loadedVersion == version)
    }

    private func makeDatabasePool() throws -> DatabaseQueue {
        let dbPool = try DatabaseQueue()
        try GRDBPoolProvider.migrator.migrate(dbPool)
        return dbPool
    }
}

import Foundation
internal import GRDB
import Sync
import Testing
@testable import Data

@Suite
struct SyncVersionGeneratorTests {
    @Test("Первая версия получает счётчик 0 и сохраняет ID этого устройства")
    func firstVersionStartsAtZeroAndCreatesDeviceID() async throws {
        let dbQueue = try makeDatabaseQueue()

        let version = try await dbQueue.write { db in
            try SyncVersionGenerator().next(in: db)
        }
        let state = try await dbQueue.read { db in
            try SyncStateDB.fetchOne(db, key: "deviceID")
        }
        let savedVersion = try await dbQueue.read { db in
            try SyncStateDB.fetchOne(db, key: "version")
        }
        let deviceIDString = try #require(state.flatMap { String(data: $0.value, encoding: .utf8) })
        let deviceID = try #require(UUID(uuidString: deviceIDString))
        let decodedSavedVersion = try JSONDecoder().decode(
            SyncVersion.self,
            from: try #require(savedVersion).value
        )

        #expect(version.logicalCounter == 0)
        #expect(version.deviceID == deviceID)
        #expect(decodedSavedVersion == version)
    }

    @Test("При одинаковом физическом времени каждая новая версия увеличивает логический счётчик")
    func incrementsLogicalCounterWhenPhysicalTimeDoesNotAdvance() async throws {
        let dbQueue = try makeDatabaseQueue()
        let deviceID = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
        let physicalTime = Date(timeIntervalSince1970: 4_000_000_000)
        let storedVersion = SyncVersion(
            physicalTime: physicalTime,
            logicalCounter: 6,
            deviceID: deviceID
        )

        try await dbQueue.write { db in
            try SyncStateDB(key: "deviceID", value: Data(deviceID.uuidString.utf8)).insert(db)
            try SyncStateDB(key: "version", value: JSONEncoder().encode(storedVersion)).insert(db)
        }

        let versions = try await dbQueue.write { db in
            [
                try SyncVersionGenerator().next(in: db),
                try SyncVersionGenerator().next(in: db),
            ]
        }

        #expect(versions.map(\.physicalTime) == [physicalTime, physicalTime])
        #expect(versions.map(\.logicalCounter) == [7, 8])
        #expect(versions.allSatisfy { $0.deviceID == deviceID })
    }

    @Test("Новая локальная версия становится новее полученной удалённой версии")
    func nextVersionAdvancesPastLatestRemoteMetadata() async throws {
        let dbQueue = try makeDatabaseQueue()
        let localDeviceID = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
        let remoteDeviceID = UUID(uuidString: "00000000-0000-0000-0000-000000000002")!
        let remoteVersion = SyncVersion(
            physicalTime: Date(timeIntervalSince1970: 4_000_000_000),
            logicalCounter: 12,
            deviceID: remoteDeviceID
        )
        let remotePayload = SyncPayload(
            recordID: UUID(),
            dataType: SyncDataType(rawValue: "weight"),
            version: remoteVersion,
            isDeleted: false,
            data: Data()
        )

        try await dbQueue.write { db in
            try SyncStateDB(key: "deviceID", value: Data(localDeviceID.uuidString.utf8)).insert(db)
            try SyncMetadataDB(payload: remotePayload).insert(db)
        }

        let localVersion = try await dbQueue.write { db in
            try SyncVersionGenerator().next(in: db)
        }

        #expect(localVersion.physicalTime == remoteVersion.physicalTime)
        #expect(localVersion.logicalCounter == remoteVersion.logicalCounter + 1)
        #expect(localVersion.deviceID == localDeviceID)
        #expect(localVersion > remoteVersion)
    }

    private func makeDatabaseQueue() throws -> DatabaseQueue {
        let dbQueue = try DatabaseQueue()
        try GRDBPoolProvider.migrator.migrate(dbQueue)
        return dbQueue
    }
}

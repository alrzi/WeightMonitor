import Domain
import Foundation
internal import GRDB
import Sync
import Testing
@testable import Data

/// Правила синхронизации весов между устройствами.
///
/// 1. Более новое изменение заменяет более старое.
///
/// Если телефон A и телефон B изменили один вес, применяется изменение с более новой версией.
/// Это позволяет обоим устройствам прийти к одному состоянию записи.
///
/// 2. Устаревшее изменение с другого устройства не меняет локальные данные.
///
/// Если телефон B был офлайн и позднее прислал версию веса, созданную до уже применённого
/// изменения на телефоне A, телефон A сохраняет своё более новое состояние.
///
/// 3. Удаление не должно отменяться старым обновлением.
///
/// Если на телефоне A вес удалили, а телефон B был офлайн и позднее отправил старую версию
/// этого веса, запись не должна появиться снова. Поэтому система сохраняет факт удаления
/// вместе с версией и передаёт его на другое устройство как обычное изменение. Такое состояние
/// удалённой записи называется tombstone.
///
/// 4. Локальные изменения нужно передать другому устройству.
///
/// Когда пользователь создаёт, редактирует или удаляет вес на телефоне A, изменение сохраняется
/// в очереди отправки. Если телефон B сейчас офлайн, изменение не теряется и будет отправлено,
/// когда синхронизация снова станет доступна.
///
/// 5. Отправленное изменение считается завершённым только после подтверждения.
///
/// После отправки телефон A ещё не знает, получил ли телефон B изменение. Оно остаётся в очереди,
/// пока B не пришлёт acknowledgement — ответ о получении конкретного изменения. После этого A
/// перестаёт повторно отправлять его; без ответа изменение остаётся в очереди для повторной отправки.
///
/// 6. Записи разных типов не конфликтуют из-за одинакового ID.
///
/// Вес и заметка могут случайно иметь одинаковый ID. Для синхронизации это разные записи,
/// потому что их определяет сочетание типа данных и ID: `weight / 123` и `note / 123`.
///
/// 7. Локальное изменение после удалённого становится более новым.
///
/// Если телефон A получил изменение с телефона B, а затем пользователь изменил ту же запись
/// на A, новая версия A должна быть новее версии B. Иначе телефон B может ошибочно посчитать
/// новое локальное изменение устаревшим.
@Suite
struct GRDBSyncResourceTests {
    private let weightDataType = SyncDataType(rawValue: "weight")
    private let retryPolicy = SyncRetryPolicy(
        maximumAttemptCount: 3,
        acknowledgementTimeout: 60
    )

    @Test("При получении устаревшего изменения с другого устройства сохраняет более новую локальную запись")
    func test_payloadApplierKeepsNewerWeightWhenStalePayloadArrives() async throws {
        // GIVEN
        let dbPool = try makeDatabasePool()
        let applier = GRDBSyncResource<WeightDB>(dbPool: dbPool)
        let weight = makeWeight()
        let newer = makePayload(recordID: weight.id, createdAt: 2_000, data: try JSONEncoder().encode(weight))
        let stale = makePayload(recordID: weight.id, createdAt: 1_000, data: try JSONEncoder().encode(weight))

        // WHEN
        let didApplyNewer = try await applier.apply(newer)
        let didApplyStale = try await applier.apply(stale)

        // THEN
        #expect(didApplyNewer)
        #expect(!didApplyStale)
    }

    @Test("Созданный на этом устройстве вес сохраняется в очереди, чтобы отправиться другому устройству после его возвращения в сеть")
    func test_createStoresWeightMetadataAndPendingOutboxPayload() async throws {
        // GIVEN
        let dbPool = try makeDatabasePool()
        let store = GRDBSyncResource<WeightDB>(dbPool: dbPool)
        let weight = makeWeight()

        // WHEN
        try await store.create(weight)

        // THEN
        let result = try await dbPool.read { db in
            (
                try WeightDB.fetchOne(db, key: weight.id.uuidString),
                try SyncMetadataDB.fetchOne(db, key: ["dataType": weightDataType.rawValue, "recordID": weight.id.uuidString]),
                try OutboxDB.fetchAll(db).first
            )
        }

        #expect(try result.0?.toPlain() == weight)
        #expect(result.1?.isDeleted == false)
        #expect(result.1?.dataType == weightDataType.rawValue)
        #expect(result.2?.status == .pending)
        let pending = try await GRDBSyncOutboxStore(
            dbPool: dbPool,
            retryPolicy: retryPolicy
        ).retryablePayloads()
        #expect(try JSONDecoder().decode(Weight.self, from: #require(pending.first).data) == weight)
    }

    @Test("При ошибке помещения локального изменения в outbox откатывает запись и sync-метаданные")
    func test_createRollsBackWeightAndMetadataWhenOutboxInsertFails() async throws {
        // GIVEN
        let dbPool = try makeDatabasePool()
        let store = GRDBSyncResource<WeightDB>(dbPool: dbPool)
        let weight = makeWeight()

        try await dbPool.write { db in
            try db.execute(sql: "CREATE TRIGGER failOutbox BEFORE INSERT ON outbox BEGIN SELECT RAISE(ABORT, 'failure'); END")
        }

        // WHEN
        var didFail = false

        do {
            try await store.create(weight)
        }
        catch {
            // The trigger intentionally fails the transaction.
            didFail = true
        }

        // THEN
        #expect(didFail)
        let result = try await dbPool.read { db in
            (
                try WeightDB.fetchOne(db, key: weight.id.uuidString),
                try SyncMetadataDB.fetchOne(db, key: ["dataType": weightDataType.rawValue, "recordID": weight.id.uuidString])
            )
        }

        #expect(result.0 == nil)
        #expect(result.1 == nil)
    }

    @Test("Удаление веса передаётся другому устройству как изменение с версией, чтобы старый payload не восстановил удалённую запись")
    func test_deleteRemovesWeightAndStoresTombstoneAndOutboxPayload() async throws {
        // GIVEN
        let dbPool = try makeDatabasePool()
        let store = GRDBSyncResource<WeightDB>(dbPool: dbPool)
        let weight = makeWeight()

        try await store.create(weight)

        // WHEN
        try await store.delete(recordID: weight.id)

        // THEN
        let result = try await dbPool.read { db in
            (
                try WeightDB.fetchOne(db, key: weight.id.uuidString),
                try SyncMetadataDB.fetchOne(db, key: ["dataType": weightDataType.rawValue, "recordID": weight.id.uuidString]),
                try OutboxDB.fetchAll(db).last
            )
        }

        #expect(result.0 == nil)
        #expect(result.1?.isDeleted == true)
        #expect(result.2?.status == .pending)
    }

    @Test("При подготовке полного состояния для передачи другому устройству (snapshot) включает актуальные и удалённые записи")
    func test_snapshotStoreIncludesCurrentWeightsAndTombstones() async throws {
        // GIVEN
        let dbPool = try makeDatabasePool()
        let mutationStore = GRDBSyncResource<WeightDB>(dbPool: dbPool)
        let snapshotStore = GRDBSyncResource<WeightDB>(dbPool: dbPool)
        let existingWeight = makeWeight()
        let deletedWeight = makeWeight(mass: 80)
        try await mutationStore.create(existingWeight)
        try await mutationStore.create(deletedWeight)
        try await mutationStore.delete(recordID: deletedWeight.id)

        // WHEN
        let snapshotPayloads = try await snapshotStore.snapshotPayloads()

        // THEN
        #expect(snapshotPayloads.count == 2)

        let existingSnapshotPayload = try #require(snapshotPayloads.first { $0.recordID == existingWeight.id })
        let tombstoneSnapshotPayload = try #require(snapshotPayloads.first { $0.recordID == deletedWeight.id })

        #expect(existingSnapshotPayload.isDeleted == false)
        #expect(try JSONDecoder().decode(Weight.self, from: existingSnapshotPayload.data) == existingWeight)
        #expect(tombstoneSnapshotPayload.isDeleted)
        #expect(tombstoneSnapshotPayload.data.isEmpty)
        #expect(tombstoneSnapshotPayload.dataType == weightDataType)
    }

    @Test("До подтверждения другим устройством создание и обновление веса хранятся как два отдельных изменения в очереди отправки")
    func test_updateReplacesWeightAndEnqueuesNewPayload() async throws {
        // GIVEN
        let dbPool = try makeDatabasePool()
        let store = GRDBSyncResource<WeightDB>(dbPool: dbPool)
        let weight = makeWeight()
        let updatedWeight = Weight(id: weight.id, createdAt: weight.createdAt, mass: 74.5)

        try await store.create(weight)

        // WHEN
        try await store.update(updatedWeight)

        // THEN
        let result = try await dbPool.read { db in
            (
                try WeightDB.fetchOne(db, key: weight.id.uuidString),
                try OutboxDB.fetchAll(db)
            )
        }

        #expect(try result.0?.toPlain() == updatedWeight)
        // Outbox сохраняет оба локальных изменения, пока они не подтверждены другим устройством.
        #expect(result.1.count == 2)
    }

    @Test("Не изменяет локальную БД, если с другого устройства пришёл payload неверного типа или идентификатора")
    func test_remotePayloadRejectsWrongTypeAndIdentifierWithoutWriting() async throws {
        // GIVEN
        let dbPool = try makeDatabasePool()
        let resource = GRDBSyncResource<WeightDB>(dbPool: dbPool)
        let weight = makeWeight()
        let wrongID = makePayload(recordID: UUID(), data: try JSONEncoder().encode(weight))
        let wrongType = SyncPayload(
            recordID: weight.id,
            dataType: SyncDataType(rawValue: "note"),
            version: wrongID.version,
            isDeleted: false,
            data: try JSONEncoder().encode(weight)
        )

        // WHEN
        let didApplyWrongID = try await resource.apply(wrongID)
        let didApplyWrongType = try await resource.apply(wrongType)

        // THEN
        #expect(!didApplyWrongID)
        #expect(!didApplyWrongType)
        #expect(try await resource.snapshotPayloads().isEmpty)
        #expect(try await dbPool.read { try WeightDB.fetchCount($0) } == 0)
    }

    @Test("Вес и заметка с одинаковым ID не конфликтуют, потому что синхронизация различает их по типу данных и ID")
    func test_resourcesWithSameIdentifierKeepSeparateMetadataAndSnapshots() async throws {
        // GIVEN
        let dbPool = try makeDatabasePool()
        try await dbPool.write { db in
            try db.create(table: NoteSyncRecord.databaseTableName) { table in
                table.column("id", .text).primaryKey()
                table.column("text", .text).notNull()
            }
        }
        let weights = GRDBSyncResource<WeightDB>(dbPool: dbPool)
        let notes = GRDBSyncResource<NoteSyncRecord>(dbPool: dbPool)
        let weight = makeWeight()
        let note = NoteSyncValue(id: weight.id, text: "Shared identifier")

        // WHEN
        try await weights.create(weight)
        try await notes.create(note)
        try await weights.delete(recordID: weight.id)

        // THEN
        let weightSnapshot = try #require(try await weights.snapshotPayloads().first)
        let noteSnapshot = try #require(try await notes.snapshotPayloads().first)
        #expect(weightSnapshot.isDeleted)
        #expect(!noteSnapshot.isDeleted)
        #expect(try JSONDecoder().decode(NoteSyncValue.self, from: noteSnapshot.data) == note)
        #expect(try await dbPool.read { try SyncMetadataDB.fetchCount($0) } == 2)

        // GIVEN
        let newerNote = NoteSyncValue(id: note.id, text: "Remote update")
        let remote = SyncPayload(
            recordID: note.id,
            dataType: notes.dataType,
            version: SyncVersion(physicalTime: .distantFuture, logicalCounter: 0, deviceID: UUID()),
            isDeleted: false,
            data: try JSONEncoder().encode(newerNote)
        )
        // WHEN
        let didApplyRemoteNote = try await notes.apply(remote)
        let didApplyDuplicateRemoteNote = try await notes.apply(remote)

        // THEN
        #expect(didApplyRemoteNote)
        #expect(!didApplyDuplicateRemoteNote)
        #expect(try await weights.snapshotPayloads().first?.isDeleted == true)
        #expect(
            try await GRDBSyncOutboxStore(
                dbPool: dbPool,
                retryPolicy: retryPolicy
            ).retryablePayloads().count == 3
        )
    }

    @Test("Изменение веса после получения удалённой версии становится новее неё, а deleteAll передаёт удаление каждой записи другому устройству")
    func test_localMutationAdvancesPastRemoteVersionAndDeleteAllProducesTombstones() async throws {
        // GIVEN
        let dbPool = try makeDatabasePool()
        let resource = GRDBSyncResource<WeightDB>(dbPool: dbPool)
        let weight = makeWeight()
        let remote = makePayload(
            recordID: weight.id,
            createdAt: Date().timeIntervalSince1970 + 86_400,
            data: try JSONEncoder().encode(weight)
        )
        // WHEN
        let didApplyRemote = try await resource.apply(remote)
        try await resource.update(weight)
        let local = try #require(try await resource.snapshotPayloads().first)
        try await resource.create(makeWeight())
        try await resource.deleteAll()

        // THEN
        #expect(didApplyRemote)
        #expect(local.version > remote.version)
        let snapshots = try await resource.snapshotPayloads()
        #expect(snapshots.count == 2)
        #expect(snapshots.filter(\.isDeleted).count == snapshots.count)
        #expect(try await dbPool.read { try WeightDB.fetchCount($0) } == 0)
        #expect(
            try await GRDBSyncOutboxStore(
                dbPool: dbPool,
                retryPolicy: retryPolicy
            ).retryablePayloads().count == 4
        )
        #expect(try await !resource.apply(remote))
    }

    private func makeDatabasePool() throws -> DatabaseQueue {
        let dbPool = try DatabaseQueue()
        try GRDBPoolProvider.migrator.migrate(dbPool)
        return dbPool
    }

    private func makePayload(
        recordID: UUID,
        isDeleted: Bool = false,
        createdAt: TimeInterval = 1_000,
        data: Data = Data()
    ) -> SyncPayload {
        SyncPayload(
            recordID: recordID,
            dataType: weightDataType,
            version: SyncVersion(
                physicalTime: Date(timeIntervalSince1970: createdAt),
                logicalCounter: 1,
                deviceID: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
            ),
            isDeleted: isDeleted,
            data: data
        )
    }

    private func makeWeight(mass: Double = 75) -> Weight {
        Weight(
            createdAt: Date(timeIntervalSince1970: 1_000),
            mass: mass
        )
    }

    private func status(of payloadID: UUID, in dbPool: any DatabaseWriter) async throws -> OutboxStatus? {
        try await dbPool.read { db in
            try OutboxDB.fetchOne(db, key: payloadID.uuidString)?.status
        }
    }
}

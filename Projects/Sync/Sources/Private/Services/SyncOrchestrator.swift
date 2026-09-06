import Foundation
import Sync

final class SyncOrchestrator {
    // MARK: - Private properties

    private let outboxStore: any SyncOutboxStore
    private let transport: any SyncTransport

    private var isFlushing = false

    // MARK: - Lifecycle

    init(
        outboxStore: some SyncOutboxStore,
        transport: some SyncTransport
    ) {
        self.outboxStore = outboxStore
        self.transport = transport
    }

    // MARK: - Public methods

    /// Отправляет накопленные локальные изменения из исходящей очереди синхронизации.
    ///
    /// Вызывайте после сохранения локальных изменений или восстановления связи,
    /// чтобы передать ожидающие отправки данные и повторить неудачные попытки.
    /// Сначала восстанавливает прерванные отправки, затем последовательно обрабатывает
    /// текущую выборку очереди. Новые записи обрабатываются при следующем вызове.
    ///
    /// После отправки запись ожидает подтверждения от другого устройства:
    /// синхронизация завершается только при вызове `acknowledge(_:)`.
    /// При ошибке отправки запись помечается как неудачная, и обработка продолжается.
    /// Если отправка очереди уже выполняется, повторный вызов сразу возвращается.
    ///
    /// - Throws: Ошибка чтения или изменения состояния очереди, которую не удалось
    ///   обработать переводом записи в состояние неудачной отправки.
    func flush() async throws {
        guard !isFlushing else {
            return
        }

        isFlushing = true
        defer { isFlushing = false }

        try await outboxStore.recoverInterruptedDeliveries()

        for payload in try await outboxStore.pendingPayloads() {
            try await outboxStore.markSending(payloadID: payload.id)

            do {
                try transport.send(.payload(payload))
                try await outboxStore.markAwaitingAcknowledgement(payloadID: payload.id)
            }
            catch {
                try await outboxStore.markFailed(payloadID: payload.id)
            }
        }
    }

    func acknowledge(_ acknowledgement: SyncAcknowledgement) async throws {
        try await outboxStore.markSynced(payloadID: acknowledgement.payloadID)
    }

    func send(snapshot: SyncSnapshot) async throws {
        try transport.send(.snapshot(snapshot))
    }
}

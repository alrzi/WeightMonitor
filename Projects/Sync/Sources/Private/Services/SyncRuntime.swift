import AsyncAlgorithms
import OSLog
import Sync

final actor SyncRuntime: SyncService {
    // MARK: - Private properties

    private let transport: WatchConnectivitySyncTransport
    private let syncTransport: any SyncTransport
    private let outboxStore: any SyncOutboxStore
    private let resourceRegistry: SyncResourceRegistry
    private var eventTask: Task<Void, Never>?

    // MARK: - Lifecycle

    init(
        outboxStore: some SyncOutboxStore,
        resources: [any SyncResource],
    ) {
        let transport = WatchConnectivitySyncTransport(session: WatchConnectivitySessionAdapter())
        let resourceRegistry = SyncResourceRegistry(resources: resources)
        self.outboxStore = outboxStore
        self.resourceRegistry = resourceRegistry
        self.syncTransport = transport
        self.transport = transport
    }

    // MARK: - Public methods

    nonisolated func start() {
        Task { [weak self] in
            await self?.startIfNeeded()
        }
    }

    nonisolated func stop() {
        Task { [weak self] in
            await self?.stopIfNeeded()
        }
    }

    // MARK: - Private methods

    private func startIfNeeded() {
        guard eventTask == nil else {
            return
        }

        eventTask = Task { [weak self] in
            await self?.consumeEvents()
        }
    }

    private func stopIfNeeded() {
        eventTask?.cancel()
        eventTask = nil
    }

    private func consumeEvents() async {
        let transportEvents = transport.activate()
            .map { RuntimeEvent.transport($0) }
        let outboxEvents = AsyncStream<Int>.restartingAfterFailure(
            makeStream: { [outboxStore] in await outboxStore.observePayloadCount() },
            onError: { error in
                Logger.weightMonitorSync.error("Failed to observe sync outbox: \(error.localizedDescription, privacy: .public)")
            }
        )
        .removeDuplicates()
        .map { _ in RuntimeEvent.outboxChanged }

        for await event in merge(transportEvents, outboxEvents) {
            switch event {
            case .transport(.envelope(let envelope)):
                await receive(envelope)

            case .transport(.sessionDidBecomeReady):
                await flushOutbox()

            case .outboxChanged where transport.isReady:
                await flushOutbox()

            case .outboxChanged:
                break
            }
        }
    }

    private func receive(_ envelope: SyncEnvelope) async {
        do {
            switch envelope {
            case .acknowledgement(let acknowledgement):
                try await outboxStore.markSynced(payloadID: acknowledgement.payloadID)

            case .payload(let payload):
                _ = try await resourceRegistry.apply(payload)
                try syncTransport.send(.acknowledgement(.init(payloadID: payload.id)))
            }
        }
        catch {
            Logger.weightMonitorSync.error("\(envelope.processingErrorMessage, privacy: .public): \(error.localizedDescription, privacy: .public)")
        }
    }

    private func flushOutbox() async {
        do {
            for payload in try await outboxStore.retryablePayloads() {
                try await outboxStore.markSending(payloadID: payload.id)

                do {
                    try syncTransport.send(.payload(payload))
                    try await outboxStore.markAwaitingAcknowledgement(payloadID: payload.id)
                }
                catch {
                    try await outboxStore.markFailed(payloadID: payload.id)
                }
            }
        }
        catch {
            Logger.weightMonitorSync.error("Failed to flush sync outbox: \(error.localizedDescription, privacy: .public)")
        }
    }

    private enum RuntimeEvent: Sendable {
        case transport(WatchConnectivitySyncTransportEvent)
        case outboxChanged
    }
}

private extension SyncEnvelope {
    // MARK: - Private properties

    var processingErrorMessage: String {
        switch self {
        case .acknowledgement:
            "Failed to process sync acknowledgement"

        case .payload:
            "Failed to process sync payload"
        }
    }
}

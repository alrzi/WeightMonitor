import AsyncAlgorithms
import OSLog
import Sync

final actor SyncRuntime: SyncService {
    // MARK: - Private properties

    private let transport: WatchConnectivitySyncTransport
    private let syncTransport: any SyncTransport
    private let outboxStore: any SyncOutboxStore
    private let resourceRegistry: SyncResourceRegistry
    private let flushRequests: AsyncStream<Void>
    nonisolated private let flushContinuation: AsyncStream<Void>.Continuation
    private var isStarted = false

    // MARK: - Lifecycle

    init(
        outboxStore: some SyncOutboxStore,
        resources: [any SyncResource],
    ) {
        let transport = WatchConnectivitySyncTransport(session: WatchConnectivitySessionAdapter())
        let resourceRegistry = SyncResourceRegistry(resources: resources)
        let (flushRequests, flushContinuation) = AsyncStream.makeStream(
            of: Void.self,
            bufferingPolicy: .bufferingNewest(1)
        )

        self.flushContinuation = flushContinuation
        self.flushRequests = flushRequests
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

    nonisolated func requestFlush() {
        flushContinuation.yield()
    }

    // MARK: - Private methods

    private func startIfNeeded() async {
        guard !isStarted else {
            return
        }

        isStarted = true
        await consumeEvents()
    }

    private func consumeEvents() async {
        let transportEvents = transport.activate().map { RuntimeEvent.transport($0) }
        let flushEvents = flushRequests.map { RuntimeEvent.flushRequested }

        for await event in merge(transportEvents, flushEvents) {
            switch event {
            case .transport(.envelope(let envelope)):
                await receive(envelope)

            case .transport(.sessionDidBecomeReady), .flushRequested:
                await flushOutbox()
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
        case flushRequested
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

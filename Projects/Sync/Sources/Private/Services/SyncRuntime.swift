import AsyncAlgorithms
import OSLog
import Sync

final actor SyncRuntime: SyncService {
    private enum RuntimeEvent: Sendable {
        case transport(WatchConnectivitySyncTransportEvent)
        case flushRequested
    }

    // MARK: - Private properties

    private let transport: WatchConnectivitySyncTransport
    private let orchestrator: SyncOrchestrator
    private let receiver: SyncReceiver
    private let resourceRegistry: SyncResourceRegistry
    private let flushRequests: AsyncStream<Void>
    private nonisolated let flushContinuation: AsyncStream<Void>.Continuation
    private var isStarted = false

    // MARK: - Lifecycle

    init(
        outboxStore: some SyncOutboxStore,
        resources: [any SyncResource]
    ) {
        let transport = WatchConnectivitySyncTransport(session: WatchConnectivitySessionAdapter())
        let resourceRegistry = SyncResourceRegistry(resources: resources)
        let receiver = SyncReceiver(resourceRegistry: resourceRegistry, transport: transport)
        let orchestrator = SyncOrchestrator(outboxStore: outboxStore, transport: transport)
        let (flushRequests, flushContinuation) = AsyncStream.makeStream(
            of: Void.self,
            bufferingPolicy: .bufferingNewest(1)
        )

        self.flushContinuation = flushContinuation
        self.flushRequests = flushRequests
        self.orchestrator = orchestrator
        self.receiver = receiver
        self.resourceRegistry = resourceRegistry
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

            case .transport(.sessionDidBecomeReady):
                await synchronizeWhenSessionIsReady()

            case .flushRequested:
                await flushOutbox()
            }
        }
    }

    private func receive(_ envelope: SyncEnvelope) async {
        do {
            switch envelope {
            case .acknowledgement(let acknowledgement):
                try await orchestrator.acknowledge(acknowledgement)

            case .payload(let payload):
                try await receiver.receive(payload)

            case .snapshot(let snapshot):
                try await receiver.receive(snapshot)
            }
        }
        catch {
            Logger.weightMonitorSync.error("\(envelope.processingErrorMessage, privacy: .public): \(error.localizedDescription, privacy: .public)")
        }
    }

    private func synchronizeWhenSessionIsReady() async {
        do {
            try await orchestrator.send(snapshot: resourceRegistry.snapshot())
            try await orchestrator.flush()
        }
        catch {
            Logger.weightMonitorSync.error("Failed to flush sync outbox: \(error.localizedDescription, privacy: .public)")
        }
    }

    private func flushOutbox() async {
        do {
            try await orchestrator.flush()
        }
        catch {
            Logger.weightMonitorSync.error("Failed to flush sync outbox: \(error.localizedDescription, privacy: .public)")
        }
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

        case .snapshot:
            "Failed to process sync snapshot"
        }
    }
}

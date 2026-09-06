import OSLog
import Sync

final actor SyncRuntime: SyncService {
    // MARK: - Private properties

    private let transport: WatchConnectivitySyncTransport
    private let orchestrator: SyncOrchestrator
    private let receiver: SyncReceiver
    private let resourceRegistry: SyncResourceRegistry

    // MARK: - Lifecycle

    init(
        outboxStore: some SyncOutboxStore,
        resources: [any SyncResource]
    ) {
        let transport = WatchConnectivitySyncTransport(session: WatchConnectivitySessionAdapter())
        let resourceRegistry = SyncResourceRegistry(resources: resources)
        let receiver = SyncReceiver(resourceRegistry: resourceRegistry, transport: transport)
        let orchestrator = SyncOrchestrator(outboxStore: outboxStore, transport: transport)

        self.orchestrator = orchestrator
        self.receiver = receiver
        self.resourceRegistry = resourceRegistry
        self.transport = transport
    }

    // MARK: - Public methods

    nonisolated func start() {
        Task { [weak self] in
            await self?.consumeTransportEvents()
        }
    }

    func flush() async throws {
        try await orchestrator.flush()
    }

    // MARK: - Private methods

    private func consumeTransportEvents() async {
        let events = transport.activate()

        for await event in events {
            switch event {
            case .envelope(let envelope):
                await receive(envelope)

            case .sessionDidBecomeReady:
                await synchronizeWhenSessionIsReady()
            }
        }
    }

    private func receive(_ envelope: SyncEnvelope) async {
        do {
            switch envelope {
            case .acknowledgement(let acknowledgement):
                try await orchestrator.acknowledge(acknowledgement)

            case .payload, .snapshot:
                try await receiver.receive(envelope)
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

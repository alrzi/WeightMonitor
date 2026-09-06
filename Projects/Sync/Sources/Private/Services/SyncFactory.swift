import Sync

public enum SyncFactory {
    public static func makeService(
        outboxStore: some SyncOutboxStore,
        resources: [any SyncResource]
    ) -> any SyncService {
        SyncRuntime(
            outboxStore: outboxStore,
            resources: resources
        )
    }
}

import Data
import Domain
import SwiftUI
import Swinject
import Sync
import SyncImplementation

@main
struct WeightMonitorWatchApp: App {
    @StateObject private var viewModel: WatchWeightViewModel
    private let syncService: any SyncService

    var body: some Scene {
        WindowGroup {
            WatchWeightView(viewModel: viewModel)
                .task {
                    await syncService.start()
                }
        }
    }

    init() {
        let poolProvider = GRDBPoolProvider()!
        let assembler = Assembler([
            WeightMonitorDataAssembly(poolProviderGRDB: poolProvider),
            DomainAssembly(),
        ])
        let weightManager = assembler.resolver.resolve(WeightManaging.self)!
        let syncRuntime = SyncFactory.makeService(
            outboxStore: assembler.resolver.resolve((any SyncOutboxStore).self)!,
            resources: [assembler.resolver.resolve((any SyncResource).self)!]
        )
        _viewModel = StateObject(
            wrappedValue: WatchWeightViewModel(weightManager: weightManager)
        )
        self.syncService = syncRuntime
    }
}

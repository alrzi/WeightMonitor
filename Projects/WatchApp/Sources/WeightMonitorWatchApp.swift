import Data
import Domain
import SwiftUI
import Swinject
import Sync
import SyncImplementation

@main
struct WeightMonitorWatchApp: App {
    private static let weightSyncDataType = SyncDataType(rawValue: "weight")

    @StateObject private var viewModel: WatchWeightViewModel
    private let weightSyncRuntime: WeightSyncRuntime

    var body: some Scene {
        WindowGroup {
            WatchWeightView(viewModel: viewModel)
                .task {
                    weightSyncRuntime.start()
                }
        }
    }

    init() {
        let poolProvider = GRDBPoolProvider()!
        let assembler = Assembler([
            WeightMonitorDataAssembly(
                poolProviderGRDB: poolProvider,
                weightSyncDataType: Self.weightSyncDataType
            ),
            DomainAssembly(),
        ])
        let weightManager = assembler.resolver.resolve(WeightManaging.self)!
        let syncRuntime = SyncFactory.makeService(
            outboxStore: assembler.resolver.resolve((any SyncOutboxStore).self)!,
            resources: [assembler.resolver.resolve((any SyncResource).self)!]
        )
        let weightSyncRuntime = WeightSyncRuntime(
            syncRuntime: syncRuntime,
            weightManager: weightManager
        )

        _viewModel = StateObject(
            wrappedValue: WatchWeightViewModel(weightManager: weightManager)
        )
        self.weightSyncRuntime = weightSyncRuntime
    }
}

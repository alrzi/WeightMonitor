//
//
//  SceneDelegate.swift
//  WeightMonitor
//
//  Created by Александр Зиновьев on 25.10.2025.
//

import SwiftUI
import Swinject
import UIKit
import WeightMonitorFeatureWeightCreation
import WeightMonitorFeatureWeightHistory
import WeightMonitorUIComponents
import WeigthMonitorData
import WeigthMonitorDomain

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    private let assembler = Assembler()
    private var resolver: Resolver { assembler.resolver }

    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else {
            return
        }

        let poolProviderGRDB = GRDBPoolProvider()!

        assembler.apply(
            assemblies: [
                WeigthMonitorDataAssembly(poolProviderGRDB: poolProviderGRDB),
                WeigthMonitorDomainAssembly(),
                WeightMonitorModulesAssembly(),
            ]
        )

        let window = UIWindow(windowScene: windowScene)
        self.window = window

        let weightCreationFactory = resolver.resolve(WeightCreationFactory.self)!
        let weightHistoryFactory = resolver.resolve(WeightHistoryFactory.self)!

        let coordinator = WeightHistoryCoordinator()

        window.rootViewController = UIHostingController(
            rootView: WeightHistoryNavigationView(
                coordinator: coordinator,
                weightHistoryFactory: weightHistoryFactory,
                weightCreationFactory: weightCreationFactory
            )
        )
        window.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
}

//
//  AppDelegate.swift
//  Media
//
//  Created by 김건우 on 6/5/25.
//

import UIKit
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    let coreDataService = CoreDataService.shared
    let userDefaultsService = UserDefaultsService.shared

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        // [필터] 초기화
        userDefaultsService.clear(forKey: \.filterCategories)
        userDefaultsService.clear(forKey: \.filterOrders)
        userDefaultsService.clear(forKey: \.filterDurations)

        CoreDataService.shared.initializeDefaultDataIfFirstRun()

        #if DEBUG
        CoreDataService.shared.generateDummy()
        #endif

        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(
        _ application: UIApplication,
        didDiscardSceneSessions sceneSessions: Set<UISceneSession>
    ) { }
}


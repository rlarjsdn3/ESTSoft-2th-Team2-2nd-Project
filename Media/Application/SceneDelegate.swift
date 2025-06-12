//
//  SceneDelegate.swift
//  Media
//
//  Created by 김건우 on 6/5/25.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
        
//        guard let windowScene = (scene as? UIWindowScene) else { return }
//
//            let storyboard = UIStoryboard(name: "OnBoardingOnBoardingViewController", bundle: nil)
//            let initialVC = storyboard.instantiateInitialViewController()!
//
//            let window = UIWindow(windowScene: windowScene)
//            window.rootViewController = initialVC
//            self.window = window
//            window.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
    }

    func sceneWillResignActive(_ scene: UIScene) {
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
    }


}


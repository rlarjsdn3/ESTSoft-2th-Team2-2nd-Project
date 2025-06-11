//
//  SceneDelegate.swift
//  Media
//
//  Created by 김건우 on 6/5/25.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    /**
     Scene이 앱에 연결될 때 호출되는 메서드
     
     탭바 컨트롤러의 외관과 각 탭의 아이콘, 타이틀을 설정함
     - 탭바 배경색을 설정하고 불투명하게 구성
     - 선택된/선택되지 않은 탭의 색상 지정
     - 각 탭(Home, Library, Interest, Setting)의 일반 상태와 선택된 상태 이미지 설정
     */
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        if let tapBarController = self.window?.rootViewController as? UITabBarController {
            // 탭바 외관 설정
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor.backgroundColor
            
            tapBarController.tabBar.standardAppearance = appearance
            tapBarController.tabBar.scrollEdgeAppearance = appearance
            
            // 선택된 탭 색상
            tapBarController.tabBar.tintColor = UIColor.primaryColor
            // 선택되지 않은 탭 색상
            tapBarController.tabBar.unselectedItemTintColor = UIColor.secondaryLabel
            
            // 각 탭의 일반 상태와 선택된 상태 이미지 설정
            if let tapBarItems = tapBarController.tabBar.items {
                // Home 탭 설정
                tapBarItems[0].image = UIImage(systemName: "house")
                tapBarItems[0].selectedImage = UIImage(systemName: "house.fill")
                tapBarItems[0].title = "Home"
                
                // Library 탭 설정
                tapBarItems[1].image = UIImage(systemName: "folder")
                tapBarItems[1].selectedImage = UIImage(systemName: "folder.fill")
                tapBarItems[1].title = "Library"

                // Interest 탭 설정
                tapBarItems[2].image = UIImage(systemName: "tag")
                tapBarItems[2].selectedImage = UIImage(systemName: "tag.fill")
                tapBarItems[2].title = "Interest"

                // Setting 탭 설정
                tapBarItems[3].image = UIImage(systemName: "gearshape")
                tapBarItems[3].selectedImage = UIImage(systemName: "gearshape.fill")
                tapBarItems[3].title = "Setting"
            }
        }
        
        guard let _ = (scene as? UIWindowScene) else { return }
        
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


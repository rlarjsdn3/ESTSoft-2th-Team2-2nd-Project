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
        guard let windowScene = scene as? UIWindowScene else { return }
        
        applyUserInterfaceStyle(from: windowScene)
        
        guard let tapBarController = self.window?.rootViewController as? UITabBarController else { return }
        
        configureTabBarAppearance(tapBarController.tabBar)
        configureTabBarItems(for: tapBarController)
    }
    
    /// 사용자 설정에 따라 라이트 / 다크 모드를 적용
    func applyUserInterfaceStyle(from windowScene: UIWindowScene) {
        let isDark = UserDefaults.standard.bool(forKey: "isDarkMode")
        if let window = windowScene.windows.first {
            window.overrideUserInterfaceStyle = isDark ? .dark : .light
        }
    }

    /// 탭바의 외형(배경색, 선택 / 비선택 색상 등)을 설정
    func configureTabBarAppearance(_ tabBar: UITabBar) {
        // 탭바 외관 설정
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.backgroundColor
        
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
        
        // 선택된 탭 색상
        tabBar.tintColor = UIColor.primaryColor
        // 선택되지 않은 탭 색상
        tabBar.unselectedItemTintColor = UIColor.secondaryLabel
    }
    
    /// 각 탭 항목의 아이콘과 타이틀을 설정합니다.
    func configureTabBarItems(for tabBarController: UITabBarController) {
        // 각 탭의 일반 상태와 선택된 상태 이미지 설정
        if let tapBarItems = tabBarController.tabBar.items {
            // Home 탭 설정
            tapBarItems[0].image = UIImage(systemName: "house")
            tapBarItems[0].selectedImage = UIImage(systemName: "house.fill")
            tapBarItems[0].title = "Home"
            
            // Interest 탭 설정
            tapBarItems[1].image = UIImage(systemName: "tag")
            tapBarItems[1].selectedImage = UIImage(systemName: "tag.fill")
            tapBarItems[1].title = "Interest"
            
            // Library 탭 설정
            tapBarItems[2].image = UIImage(systemName: "folder")
            tapBarItems[2].selectedImage = UIImage(systemName: "folder.fill")
            tapBarItems[2].title = "Library"
            
            // Setting 탭 설정
            tapBarItems[3].image = UIImage(systemName: "gearshape")
            tapBarItems[3].selectedImage = UIImage(systemName: "gearshape.fill")
            tapBarItems[3].title = "Setting"
        }
}

    func sceneDidDisconnect(_ scene: UIScene) {}
    func sceneDidBecomeActive(_ scene: UIScene) {}
    func sceneWillResignActive(_ scene: UIScene) {}
    func sceneWillEnterForeground(_ scene: UIScene) {}
    func sceneDidEnterBackground(_ scene: UIScene) {}
}


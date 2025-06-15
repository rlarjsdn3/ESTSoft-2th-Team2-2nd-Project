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

        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        let isDark = UserDefaults.standard.bool(forKey: "isDarkMode")
        window.overrideUserInterfaceStyle = isDark ? .dark : .light
        
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let onboardingStoryboard = UIStoryboard(name: "OnBoardingOnBoardingViewController", bundle: nil)
        
        if UserDefaults.standard.seenOnboarding {
            // 앱 실행시 온보딩이 완료된 경우 바로 메인화면으로 이동
            let mainVC = mainStoryboard.instantiateViewController(withIdentifier: "MainVC")
            window.rootViewController = mainVC
        } else {
            // 앱 실행시 온보딩이 아직 진행이 안됐으면 온보딩 화면으로 이동
            let onboardingVC = onboardingStoryboard.instantiateViewController(withIdentifier: "OnboardingVC")
            let nav = UINavigationController(rootViewController: onboardingVC)
            window.rootViewController = nav
        }
        
        self.window = window
        window.makeKeyAndVisible()
    }

//    func sceneDidDisconnect(_ scene: UIScene) {
//    }
//
//    func sceneDidBecomeActive(_ scene: UIScene) {
//    }
//    
    /// 사용자 설정에 따라 라이트 / 다크 모드를 적용
    private func applyUserInterfaceStyle(from windowScene: UIWindowScene) {
        let isDark = UserDefaults.standard.bool(forKey: "isDarkMode")
        if let window = windowScene.windows.first {
            window.overrideUserInterfaceStyle = isDark ? .dark : .light
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {}
    func sceneDidBecomeActive(_ scene: UIScene) {}
    func sceneWillResignActive(_ scene: UIScene) {}
    func sceneWillEnterForeground(_ scene: UIScene) {}
    func sceneDidEnterBackground(_ scene: UIScene) {}
}


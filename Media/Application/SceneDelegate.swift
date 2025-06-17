//
//  SceneDelegate.swift
//  Media
//
//  Created by 김건우 on 6/5/25.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    /// Scene이 앱에 연결될 때 호출되는 메서드
    /// - 탭바 설정 및 다크모드 적용
    /// - 온보딩 완료 여부에 따라 루트 뷰컨트롤러 설정
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        
        applyUserInterfaceStyle(to: window)
        setRootViewController(into: window)

        window.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {}
    func sceneDidBecomeActive(_ scene: UIScene) {}
    func sceneWillResignActive(_ scene: UIScene) {}
    func sceneWillEnterForeground(_ scene: UIScene) {}
    func sceneDidEnterBackground(_ scene: UIScene) {}
    
    /// UserDefaults의 다크모드 설정에 따라 인터페이스 스타일을 적용
    private func applyUserInterfaceStyle(to window: UIWindow) {
        let isDarkMode = UserDefaultsService.shared.isDarkMode
        window.overrideUserInterfaceStyle = isDarkMode ? .dark : .light
    }
    
    /// 온보딩 완료 여부에 따라 루트 뷰컨트롤러를 설정
    /// - 완료된 경우: 메인 탭바 컨트롤러(MainVC)
    /// - 미완료인 경우: 온보딩 네비게이션 컨트롤러(OnboardingVC)
    private func setRootViewController(into window: UIWindow) {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let onboardingStoryboard = UIStoryboard(name: "OnBoardingOnBoardingViewController", bundle: nil)
        
        if UserDefaults.standard.seenOnboarding {
            // 앱 실행시 온보딩이 완료된 경우 바로 메인화면으로 이동
            let mainVC = mainStoryboard.instantiateViewController(withIdentifier: "MainVC")
            
            // 탭바 설정
            if let tabBarVC = mainVC as? UITabBarController {
                TabBarConfigurator.configure(tabBarController: tabBarVC)
            }
            
            window.rootViewController = mainVC
        } else {
            // 앱 실행시 온보딩이 아직 진행이 안됐으면 온보딩 화면으로 이동
            let onboardingVC = onboardingStoryboard.instantiateViewController(withIdentifier: "OnboardingVC")
            let nav = UINavigationController(rootViewController: onboardingVC)
            window.rootViewController = nav
        }
    }
}


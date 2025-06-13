//
//  File.swift
//  Media
//
//  Created by 강민지 on 6/13/25.
//

import UIKit

/// 탭바의 외형과 항목 구성을 담당하는 설정 클래스
final class TabBarConfigurator {
    /// 주어진 탭바 컨트롤러의 외형과 아이템을 설정
    /// - Parameter tabBarController: 설정할 UITabBarController 인스턴스
    static func configure(tabBarController: UITabBarController) {
        configureAppearance(tabBarController.tabBar)
        configureItems(for: tabBarController)
    }
    
    /// 탭바의 외형(배경색, 선택 / 비선택 색상 등)을 설정
    /// - Parameter tabBar: 스타일을 적용할 UITabBar 인스턴스
    private static func configureAppearance(_ tabBar: UITabBar) {
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
    
    /// 각 탭 항목의 아이콘과 타이틀을 설정
    /// - Parameter tabBarController: 탭 아이템이 포함된 컨트롤러
    private static func configureItems(for tabBarController: UITabBarController) {
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
}

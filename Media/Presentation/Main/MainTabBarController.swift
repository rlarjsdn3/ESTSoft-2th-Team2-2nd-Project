//
//  MainTabBarController.swift
//  Media
//
//  Created by 전광호 on 6/13/25.
//

import UIKit
import TSAlertController

class MainTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBarAppearnce()
    }
    
    private func tabBarAppearnce() {
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
        
        // 각 탭의 일반 상태와 선택된 상태 이미지 설정
        if let tapBarItems = tabBar.items, tapBarItems.count >= 4 {
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
}

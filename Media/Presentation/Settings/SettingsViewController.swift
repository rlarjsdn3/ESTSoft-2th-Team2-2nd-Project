//
//  SettingsViewController.swift
//  Media
//
//  Created by 김건우 on 6/5/25.
//

import UIKit

/// 앱의 설정 화면을 담당하는 뷰 컨트롤러
/// 사용자 환경 설정 항목들을 보여주며, 상단에 커스텀 내비게이션 바를 포함함
final class SettingsViewController: StoryboardViewController {
    /// 커스텀 내비게이션 바
    @IBOutlet weak var navigationBar: NavigationBar!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 내비게이션 바 구성
        navigationBar.configure(
            title: "Settings",
            subtitle: "",
            isSearchMode: false,
            isLeadingAligned: false
        )
    }

    // MARK: - Attributes Setup
    
    override func setupAttributes() {
        super.setupAttributes()
    }
}

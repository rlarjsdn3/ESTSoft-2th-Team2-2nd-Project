//
//  StoryboardViewController.swift
//  News
//
//  Created by 김건우 on 5/31/25.
//

import UIKit

class StoryboardViewController: UIViewController, StoryboardInstantiable, Alertable {

    override func viewDidLoad() {
        super.viewDidLoad()

        setupHierachy()
        setupAttributes()
    }

    /// UI 요소들을 뷰 계층에 추가합니다.
    func setupHierachy() {
    }

    /// 뷰의 속성(색상, 폰트 등)을 설정합니다.
    func setupAttributes() {
    }
}

//
//  NavigationBarDelegate.swift
//  Media
//
//  Created by 강민지 on 6/8/25.
//

import Foundation

/// NavigationBar 내 버튼 동작을 위임받는 프로토콜
@objc protocol NavigationBarDelegate: NSObjectProtocol {
    /// 왼쪽 버튼 탭 이벤트
    @objc optional func navigationBarDidTapLeft(_ navBar: NavigationBar)
    /// 오른쪽 버튼 탭 이벤트
    @objc optional func navigationBarDidTapRight(_ navBar: NavigationBar)
}

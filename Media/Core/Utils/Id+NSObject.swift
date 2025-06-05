//
//  NSObject+id.swift
//  News
//
//  Created by 김건우 on 5/31/25.
//

import Foundation

extension NSObject {

    /// 클래스 이름을 문자열로 반환하는 정적 식별자입니다.
    ///
    /// 주로 셀 등록 시 reuseIdentifier 또는 storyboard identifier로 활용됩니다.
    static var id: String {
        NSStringFromClass(Self.self)
            .components(separatedBy: ".")
            .last ?? ""
    }
}

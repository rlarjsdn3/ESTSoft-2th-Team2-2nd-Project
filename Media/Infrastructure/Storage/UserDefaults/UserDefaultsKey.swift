//
//  UserDefaultsKey.swift
//  UserDefaultsService
//
//  Created by 김건우 on 6/5/25.
//

import Foundation

/// UserDefaults에서 사용할 키와 기본값을 함께 정의하는 구조체입니다.
struct UserDefaultsKey<Value> {

    /// UserDefaults에 저장될 키 이름입니다.
    let name: String

    /// 해당 키의 기본값입니다.
    let defaultValue: Value

    /// 키 이름과 기본값을 지정해 UserDefaultsKey를 초기화합니다.
    /// - Parameters:
    ///   - name: UserDefaults에 사용할 키 이름
    ///   - defaultValue: 해당 키의 기본값
    init(name: String, defaultValue: Value) {
        self.name = name
        self.defaultValue = defaultValue
    }
}

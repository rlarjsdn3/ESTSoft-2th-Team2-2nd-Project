//
//  Collection+Extension.swift
//  Media
//
//  Created by 김건우 on 6/11/25.
//

import Foundation

extension Collection {
    
    /// 컬렉션의 모든 요소가 주어진 조건을 만족하는지 여부를 반환합니다.
    ///
    /// - Parameter predicate: 컬렉션의 각 요소를 입력받아 조건을 판단하는 클로저입니다.
    /// - Returns: 모든 요소가 조건을 만족하면 `true`, 하나라도 만족하지 않으면 `false`를 반환합니다.
    func any(_ predicate: (Self.Element) -> Bool) -> Bool {
        for element in self {
            if !predicate(element) {
                return false
            }
        }
        return true
    }

    /// 컬렉션에 주어진 조건을 만족하는 요소가 하나라도 있는지 여부를 반환합니다.
    ///
    /// - Parameter predicate: 컬렉션의 각 요소를 입력받아 조건을 판단하는 클로저입니다.
    /// - Returns: 조건을 만족하는 요소가 하나라도 있으면 `true`, 그렇지 않으면 `false`를 반환합니다.
    func some(_ predicate: (Self.Element) -> Bool) -> Bool {
        for element in self {
            if predicate(element) {
                return true
            }
        }
        return false
    }
}

extension Collection {
    
    /// 주어진 인덱스가 범위 내에 있을 경우 해당 요소를 반환하고,
    /// 범위를 벗어나면 `nil`을 반환하는 안전한 서브스크립트입니다.
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

//
//  Collection+Extension.swift
//  Media
//
//  Created by 김건우 on 6/11/25.
//

import Foundation

extension Collection {
    
    /// 주어진 인덱스가 범위 내에 있을 경우 해당 요소를 반환하고,
    /// 범위를 벗어나면 `nil`을 반환하는 안전한 서브스크립트입니다.
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

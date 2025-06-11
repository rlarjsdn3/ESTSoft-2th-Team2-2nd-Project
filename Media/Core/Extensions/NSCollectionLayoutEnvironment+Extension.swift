//
//  NSCollectionLayoutEnvironment+Extension.swift
//  Media
//
//  Created by 김건우 on 6/11/25.
//

import UIKit

extension NSCollectionLayoutEnvironment {
    
    /// 수평 크기 클래스가 `.compact`인지 여부를 나타냅니다.
    var isHorizontalSizeClassCompact: Bool {
        self.traitCollection.horizontalSizeClass == .compact
    }
    
    /// 수직 크기 클래스가 `.compact`인지 여부를 나타냅니다.
    var isVerticalSizeClassCompact: Bool {
        self.traitCollection.verticalSizeClass == .compact
    }
}


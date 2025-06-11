//
//  UICollectionView+Extension.swift
//  Media
//
//  Created by 김건우 on 6/10/25.
//

import UIKit

extension UIScrollView {

    /// 컬렉션 뷰의 가장 상단으로 스크롤합니다.
    /// - Parameter animated: 스크롤 애니메이션 여부 (기본값: true)
    func scrollToTop(animated: Bool = true) {
        self.scrollRectToVisible(.init(x: 0, y: 0, width: 1, height: 1), animated: animated)
    }
}

//
//  UICollectionView+Extension.swift
//  Media
//
//  Created by 김건우 on 6/10/25.
//

import UIKit

extension UICollectionView {

    /// <#Description#>
    /// - Parameter animated: <#animated description#>
    func scrollToTop(animated: Bool = true) {
        self.scrollRectToVisible(.init(x: 0, y: 0, width: 1, height: 1), animated: animated)
    }
}

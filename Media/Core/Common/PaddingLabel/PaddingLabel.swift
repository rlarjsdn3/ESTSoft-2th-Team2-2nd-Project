//
//  PaddingLabel.swift
//  Media
//
//  Created by 김건우 on 6/14/25.
//

import UIKit

final class PaddingLabel: UILabel {
    
    private var edgeInset = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)
    
    override var intrinsicContentSize: CGSize {
        var contentSize = super.intrinsicContentSize
        contentSize.width += edgeInset.left + edgeInset.right
        contentSize.height += edgeInset.top + edgeInset.bottom
        
        return contentSize
    }
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: edgeInset))
    }
    
    /// 레이블의 내부 여백(padding)을 설정합니다.
    /// - Parameter padding: 레이블의 상하좌우 여백을 나타내는 `NSDirectionalEdgeInsets` 값입니다.
    func setPadding(_ padding: UIEdgeInsets) {
        self.edgeInset = padding

        self.invalidateIntrinsicContentSize()
        self.setNeedsDisplay()
    }
}

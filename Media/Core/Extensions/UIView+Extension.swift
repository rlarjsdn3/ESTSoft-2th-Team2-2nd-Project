//
//  UIView+Extension.swift
//  Media
//
//  Created by 김건우 on 6/11/25.
//

import UIKit

extension UIView {
    
    /// 뷰를 강조하기 위해 투명도와 크기를 동시에 애니메이션으로 변경합니다.
    /// - Parameters:
    ///   - opacity: 변경할 투명도 값 (기본값: 0.75)
    ///   - scale: 축소 비율 (기본값: 0.95)
    ///   - duration: 애니메이션 지속 시간 (기본값: 0.1초)
    func highlight(
        opacity: CGFloat = 0.75,
        scale: CGFloat = 0.95,
        duration: TimeInterval = 0.1
    ) {
        animateScale(scale, duration: duration)
        animateOpacity(opacity, duration: duration)
    }
    
    /// 뷰의 투명도를 지정한 값으로 애니메이션을 통해 변경합니다.
    /// - Parameters:
    ///   - opacity: 변경할 투명도 값 (기본값: 0.75)
    ///   - duration: 애니메이션 지속 시간 (기본값: 0.1초)
    func animateOpacity(
        _ opacity: CGFloat = 0.75,
        duration: TimeInterval = 0.1
    ) {
        UIView.animate(withDuration: duration) {
            self.layer.opacity = Float(opacity)
        }
    }
    
    /// 뷰의 크기를 지정한 비율로 애니메이션을 통해 축소 또는 확대합니다.
    /// - Parameters:
    ///   - scale: 변경할 스케일 비율 (기본값: 0.95)
    ///   - duration: 애니메이션 지속 시간 (기본값: 0.1초)
    func animateScale(
        _ scale: CGFloat = 0.95,
        duration: TimeInterval = 0.1
    ) {
        UIView.animate(withDuration: duration) {
            self.transform = CGAffineTransform(scaleX: scale, y: scale)
        }
    }
}

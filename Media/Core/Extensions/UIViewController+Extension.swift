//
//  UIViewController+Extension.swift
//  Media
//
//  Created by 김건우 on 6/5/25.
//

import UIKit

extension UIViewController {

    /// 자식 뷰 컨트롤러를 현재 뷰 컨트롤러에 추가하고, 해당 뷰를 지정된 컨테이너 뷰에 포함시킵니다.
    ///
    /// - Parameters:
    ///   - vc: 추가할 자식 뷰 컨트롤러
    ///   - container: 자식 뷰 컨트롤러의 뷰를 포함할 컨테이너 뷰
    func addChild(
        _ vc: UIViewController,
        to container: UIView
    ) {
        self.addChild(vc)
        container.addSubview(vc.view)
        vc.view.frame = container.bounds
        vc.didMove(toParent: self)
    }

    /// 자식 뷰 컨트롤러를 현재 뷰 컨트롤러에서 제거하고, 해당 뷰도 슈퍼뷰에서 제거합니다.
    ///
    /// - Parameter vc: 제거할 자식 뷰 컨트롤러
    func removeChild(_ vc: UIViewController) {
        vc.willMove(toParent: nil)
        vc.removeFromParent()
        vc.view.removeFromSuperview()
    }
}

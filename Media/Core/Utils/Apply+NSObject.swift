//
//  Apply+UIView.swift
//  News
//
//  Created by 김건우 on 5/31/25.
//

import UIKit

/// 인스턴스를 구성(configure)할 때 메서드 체이닝 스타일로 구성할 수 있도록 하는 마커 프로토콜입니다.
protocol Apply { }

extension Apply {

    /// 인스턴스를 클로저 기반으로 구성하고, 자신을 반환합니다.
    ///
    /// 이 메서드를 통해 객체 생성과 동시에 속성을 설정하는 코드 패턴을 간결하게 만들 수 있습니다.
    ///
    /// - Parameter configuration: 인스턴스를 수정하는 클로저. `self`를 인자로 받아 수정할 수 있습니다.
    /// - Returns: 수정이 적용된 자기 자신 (`Self`)
    @discardableResult
    @inlinable func apply(_ configuration: (Self) -> Void) -> Self {
        configuration(self)
        return self
    }
}

extension NSObject: Apply { }

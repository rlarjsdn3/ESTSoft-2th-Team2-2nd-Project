//
//  NibLodable.swift
//  News
//
//  Created by 김건우 on 6/1/25.
//

import UIKit

/// Nib 파일로부터 뷰를 로드할 수 있도록 정의한 프로토콜입니다.
protocol NibLodable {
    
    /// 연결된 Nib 파일의 이름입니다.
    /// 기본 구현에서는 타입 이름을 그대로 반환합니다.
    static var nibName: String { get }

    /// Nib 파일에서 뷰를 로드합니다.
    /// - Parameters:
    ///   - owner: Nib의 파일 소유자(보통 self 또는 nil)
    ///   - bundle: 번들 정보(기본적으로 nil 가능)
    func loadFromNib(owner: Any?)
}

extension NibLodable where Self: UIView {
    
    /// 타입 이름을 기반으로 Nib 파일 이름을 반환합니다.
    static var nibName: String {
        String(describing: self)
    }
    
    /// nibName과 연결된 UINib 인스턴스를 생성합니다.
    /// - Returns: 번들에서 로드된 UINib 객체
    static var nib: UINib {
        let bundle = Bundle(for: Self.self)
        return UINib(nibName: nibName, bundle: bundle)
    }

    /// Nib 파일에서 뷰를 로드하여 현재 뷰에 추가합니다.
    /// - Parameter owner: 파일 소유자 객체
    /// - Note: nib의 첫 번째 뷰가 self와 호환되지 않으면 앱이 중단됩니다.
    func loadFromNib(owner: Any?) {
        guard let view = Self.nib.instantiate(withOwner: owner).first as? UIView else {
            fatalError("can not instantiate \(Self.self)")
        }

        view.frame = self.bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(view)
    }
}

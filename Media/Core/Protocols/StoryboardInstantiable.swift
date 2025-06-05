//
//  StoryboardInstantiable.swift
//  News
//
//  Created by 김건우 on 6/3/25.
//

import UIKit

/// 스토리보드에서 UIViewController 인스턴스를 간편하게 생성할 수 있도록 하는 프로토콜입니다.
protocol StoryboardInstantiable {

    /// 기본 스토리보드 이름 (기본적으로 클래스 이름과 동일하게 설정됨)
    static var name: String { get }

    /// 지정된 스토리보드 이름에서 해당 뷰 컨트롤러를 초기 뷰 컨트롤러로 로드합니다.
    /// - Parameter storyboardName: 사용할 스토리보드 이름 (기본값은 클래스명)
    /// - Returns: 초기 뷰 컨트롤러로 지정된 인스턴스, 타입 캐스팅에 실패하면 nil
    static func instantiateViewController(from storyboardName: String) -> Self?
}

extension StoryboardInstantiable where Self: UIViewController {

    /// 클래스 이름을 문자열로 반환합니다. 기본 스토리보드 이름으로 사용됩니다.
    static var name: String {
        String(describing: Self.self)
    }

    /// 지정된 이름의 스토리보드를 현재 클래스의 번들에서 로드합니다.
    /// - Parameter name: 스토리보드 파일 이름
    /// - Returns: 생성된 UIStoryboard 인스턴스
    static func storyboard(_ name: String) -> UIStoryboard {
        let bundle = Bundle(for: Self.self)
        return UIStoryboard(name: name, bundle: bundle)
    }

    /// 클래스 이름과 동일한 이름의 스토리보드에서 초기 뷰 컨트롤러를 인스턴스화합니다.
    /// - Parameter storyboardName: 사용할 스토리보드 이름 (기본값은 클래스명)
    /// - Returns: 초기 뷰 컨트롤러로 지정된 인스턴스, 타입 캐스팅에 실패하면 nil
    static func instantiateViewController(from storyboardName: String = Self.name) -> Self? {
        guard let vc = Self.storyboard(storyboardName).instantiateInitialViewController() as? Self else {
            return nil
        }
        return vc
    }
}

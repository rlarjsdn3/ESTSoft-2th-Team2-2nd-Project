//
//  Toast.swift
//  Media
//
//  Created by 강민지 on 6/10/25.
//

import UIKit

/// 화면 하단에 일시적으로 메시지를 표시하는 Toast 컴포넌트
/// makeToast(message:systemName:)를 통해 생성하고, present()로 화면에 표시함
final class Toast {
    /// 실제 표시될 커스텀 뷰
    private let toastView: ToastView
    
    /// 토스트가 화면에 표시될 시간 (기본: 2초)
    private let duration: TimeInterval = 2.0

    /// Toast 객체 초기화
    /// - Parameters:
    ///   - message: 표시할 메시지
    ///   - systemName: SF Symbol 이름 (선택사항)
    private init(message: String, systemName: String?) {
        let nib = UINib(nibName: "ToastView", bundle: nil)
        self.toastView = nib.instantiate(withOwner: nil, options: nil).first as! ToastView
        self.toastView.configure(message: message, systemName: systemName)
    }

    /// Toast 인스턴스를 생성합니다
    /// - Parameters:
    ///   - message: 표시할 텍스트 메시지
    ///   - systemName: 시스템 아이콘 이름 (예: "checkmark") - nil이면 아이콘 없이 출력
    /// - Returns: 구성된 Toast 객체
    static func makeToast(_ message: String, systemName: String? = nil) -> Toast {
        return Toast(message: message, systemName: systemName)
    }

    /// 구성된 토스트를 현재 윈도우에 표시합니다.
    /// - Parameter parentView: 표시할 부모 뷰 (기본: 최상위 키 윈도우)
    func present(in parentView: UIView? = nil) {
        guard let window = parentView ?? UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else { return }

        let view = toastView
        view.alpha = 0
        window.addSubview(view)

        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.centerXAnchor.constraint(equalTo: window.centerXAnchor),
            view.bottomAnchor.constraint(equalTo: window.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            view.widthAnchor.constraint(lessThanOrEqualToConstant: 300)
        ])

        UIView.animate(withDuration: 0.3) {
            view.alpha = 1
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            UIView.animate(withDuration: 0.3, animations: {
                view.alpha = 0
            }, completion: { _ in
                view.removeFromSuperview()
            })
        }
    }
}

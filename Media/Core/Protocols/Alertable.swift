//
//  Alertable.swift
//  Media
//
//  Created by 김건우 on 6/7/25.
//

import UIKit

import TSAlertController

protocol Alertable { }

extension Alertable where Self: UIViewController {
    
    /// 사용자에게 확인 및 취소 옵션이 있는 기본 알림을 표시합니다.
    /// - Parameters:
    ///   - title: 알림창의 제목 텍스트
    ///   - message: 알림창에 표시할 메시지 내용
    ///   - onConfirm: 확인 버튼을 눌렀을 때 실행될 핸들러
    ///   - onCancel: 취소 버튼을 눌렀을 때 실행될 핸들러
    func showAlert(
        _ title: String,
        message: String,
        onConfirm: @escaping (TSAlertAction) -> Void,
        onCancel: @escaping (TSAlertAction) -> Void
    ) {
        let alertController = defaultAlertController(title, message: message)

        let okAction = TSAlertAction(title: "확인", style: .default, handler: onConfirm)
        okAction.configuration.backgroundColor = UIColor.systemBlue // 임시 색상
        okAction.configuration.titleAttributes?[.foregroundColor] = UIColor.systemBackground
        alertController.addAction(okAction)

        let cancelAction = TSAlertAction(title: "취소", style: .cancel, handler: onCancel)
        alertController.addAction(cancelAction)

        present(alertController, animated: true)
    }
    
    /// 사용자가 삭제 작업을 수행할 수 있도록 확인/취소 알림창을 표시합니다.
    /// - Parameters:
    ///   - title: 알림창의 제목 텍스트
    ///   - message: 알림창에 표시할 메시지 내용
    ///   - onConfirm: 삭제 버튼을 눌렀을 때 실행될 핸들러
    ///   - onCancel: 취소 버튼을 눌렀을 때 실행될 핸들러
    func showDeleteAlert(
        _ title: String,
        message: String,
        onConfirm: @escaping (TSAlertAction) -> Void,
        onCancel: @escaping (TSAlertAction) -> Void
    ) {
        let alertController = defaultAlertController(title, message: message)

        let okAction = TSAlertAction(title: "삭제", style: .destructive, handler: onConfirm)
        okAction.configuration.titleAttributes?[.foregroundColor] = UIColor.systemBackground
        alertController.addAction(okAction)

        let cancelAction = TSAlertAction(title: "취소", style: .cancel, handler: onCancel)
        alertController.addAction(cancelAction)

        present(alertController, animated: true)
    }
    
    /// 텍스트 필드가 포함된 알림창을 표시합니다. 사용자의 입력과 확인/취소 동작을 처리할 수 있습니다.
    /// - Parameters:
    ///   - title: 알림창의 제목 텍스트
    ///   - message: 알림창에 표시할 메시지 내용
    ///   - defaultText: 텍스트 필드에 처음에 쓰여질 문자열 (옵션)
    ///   - placeholder: 텍스트 필드에 표시할 플레이스홀더 문자열 (옵션)
    ///   - onConfirm: 확인 버튼을 눌렀을 때 실행될 핸들러. 사용자 입력값이 함께 전달됩니다.
    ///   - onCancel: 취소 버튼을 눌렀을 때 실행될 핸들러
    func showTextFieldAlert(
        _ title: String,
        message: String,
        defaultText: String? = nil,
        placeholder: String? = nil,
        onConfirm: @escaping ((TSAlertAction, String)) -> Void,
        onCancel: @escaping (TSAlertAction) -> Void
    ) {
        let alertController = defaultAlertController(title, message: message)

        alertController.addTextField {
            $0.text = defaultText
            $0.placeholder = placeholder
        }

        let okAction = TSAlertAction(title: "확인", style: .default) { action in
            onConfirm((action, alertController.textFields?.first?.text ?? ""))
        }
        okAction.configuration.backgroundColor = UIColor.systemBlue // 임시 색상
        okAction.configuration.titleAttributes?[.foregroundColor] = UIColor.systemBackground
        alertController.addAction(okAction)
        alertController.preferredAction = okAction

        let cancelAction = TSAlertAction(title: "취소", style: .cancel, handler: onCancel)
        alertController.addAction(cancelAction)

        present(alertController, animated: true)
    }


    /// 기본 설정이 적용된 알림 컨트롤러를 생성합니다.
    /// - Parameters:
    ///   - title: 알림창의 제목 텍스트
    ///   - message: 알림창에 표시할 메시지 내용
    /// - Returns: 기본 애니메이션 및 옵션이 적용된 `TSAlertController` 인스턴스
    private func defaultAlertController(
        _ title: String,
        message: String
    ) -> TSAlertController {
        let alertController = TSAlertController(
            title: title,
            message: message,
            options: [.dismissOnSwipeDown, .interactiveScaleAndDrag],
            preferredStyle: .alert
        )
        alertController.configuration.enteringTransition = .slideUp
        alertController.configuration.exitingTransition = .slideDown
        alertController.configuration.headerAnimation = .slideUp
        alertController.configuration.buttonGroupAnimation = .slideUp

        if traitCollection.horizontalSizeClass == .regular {
            alertController.viewConfiguration.size = .init(
                width: .proportional(minimumRatio: 0.4, maximumRatio: 0.8),
                height: .proportional()
            )
        }
        return alertController
    }
}

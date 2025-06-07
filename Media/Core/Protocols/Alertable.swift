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

    func showAlert(
        _ title: String,
        message: String,
        onConfirm: @escaping ((TSAlertAction)) -> Void,
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

    func showTextFieldAlert(
        _ title: String,
        message: String,
        placeholder: String? = nil,
        onConfirm: @escaping ((TSAlertAction, String)) -> Void,
        onCancel: @escaping (TSAlertAction) -> Void
    ) {
        let alertController = defaultAlertController(title, message: message)

        alertController.addTextField {
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

    private func defaultAlertController(_ title: String, message: String) -> TSAlertController {
        let alertController = TSAlertController(
            title: title,
            message: message,
            options: [.dismissOnSwipeDown, .dismissOnTapOutside],
            preferredStyle: .alert
        )
        alertController.configuration.enteringTransition = .slideUp
        alertController.configuration.exitingTransition = .slideDown
        alertController.configuration.headerAnimation = .slideUp
        alertController.configuration.buttonGroupAnimation = .slideUp
        return alertController
    }
}

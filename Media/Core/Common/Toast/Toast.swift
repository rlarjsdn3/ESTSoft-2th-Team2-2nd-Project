//
//  Toast.swift
//  Media
//
//  Created by 강민지 on 6/10/25.
//

import UIKit

final class Toast {
    private let toastView: ToastView
    private let duration: TimeInterval = 2.0

    private init(message: String, systemName: String?) {
        let nib = UINib(nibName: "ToastView", bundle: nil)
        self.toastView = nib.instantiate(withOwner: nil, options: nil).first as! ToastView
        self.toastView.configure(message: message, systemName: systemName)
    }

    static func makeToast(_ message: String, systemName: String? = nil) -> Toast {
        return Toast(message: message, systemName: systemName)
    }

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

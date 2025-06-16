//
//  Shimmer.swift
//  Media
//
//  Created by Heejung Yang on 6/16/25.
//

import UIKit

extension UIView {
    func startShimmeringOverlay() {
        stopShimmeringOverlay() // 중복 방지

        let lightColor = UIColor.white.withAlphaComponent(0.4).cgColor
        let darkColor = UIColor.black.withAlphaComponent(0.1).cgColor

        let gradient = CAGradientLayer()
        gradient.name = "shimmerLayer"
        gradient.colors = [darkColor, lightColor, darkColor]
        gradient.locations = [0.0, 0.5, 1.0]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradient.frame = CGRect(x: -bounds.width, y: 0, width: bounds.width * 3, height: bounds.height)

        let animation = CABasicAnimation(keyPath: "transform.translation.x")
        animation.fromValue = -bounds.width
        animation.toValue = bounds.width
        animation.duration = 1.4
        animation.repeatCount = .infinity

        gradient.add(animation, forKey: "shimmerMove")
        self.layer.addSublayer(gradient)
    }

    func stopShimmeringOverlay() {
        layer.sublayers?.removeAll(where: { $0.name == "shimmerLayer" })
    }
}

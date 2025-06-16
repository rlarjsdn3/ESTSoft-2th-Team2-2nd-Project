//
//  Shimmer.swift
//  Media
//
//  Created by Heejung Yang on 6/16/25.
//

import UIKit

extension UIView {

    func startShimmering() {
        let light = UIColor(white: 0.0, alpha: 0.1).cgColor
        let dark = UIColor.black.cgColor

        let gradient = CAGradientLayer()
        gradient.colors = [dark, light, dark]
        gradient.frame = CGRect(x: -bounds.width, y: 0, width: 3 * bounds.width, height: bounds.height)
        gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.525) // 약간 기울임
        gradient.locations = [0.4, 0.5, 0.6]

        self.layer.mask = gradient

        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [0.0, 0.1, 0.2]
        animation.toValue = [0.8, 0.9, 1.0]
        animation.duration = 1.5
        animation.repeatCount = .infinity

        gradient.add(animation, forKey: "shimmer")
    }

    func stopShimmering() {
        self.layer.mask = nil
    }
}

//
//  Shimmer.swift
//  Media
//
//  Created by Heejung Yang on 6/16/25.
//

import UIKit

private let shimmerTag = 9999

extension UIView {

    func startShimmer() {
        stopShimmer()

        let shimmer = ShimmerView(frame: bounds)
        shimmer.tag = shimmerTag
        shimmer.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(shimmer)
        shimmer.startAnimating()
    }

    func stopShimmer() {
        if let shimmer = subviews.first(where: { $0.tag == shimmerTag }) as? ShimmerView {
            shimmer.stopAnimating() 
            shimmer.removeFromSuperview()
        }
    }
}

final class ShimmerView: UIView {

    private let gradientLayer = CAGradientLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = false
        backgroundColor = .clear
        setupGradient()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        isUserInteractionEnabled = false
        backgroundColor = .clear
        setupGradient()
    }

    private func setupGradient() {
        let lightColor = UIColor.white.withAlphaComponent(0.4).cgColor
        let darkColor = UIColor.black.withAlphaComponent(0.1).cgColor

        gradientLayer.colors = [darkColor, lightColor, darkColor]
        gradientLayer.locations = [0.0, 0.5, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        layer.addSublayer(gradientLayer)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = CGRect(x: -bounds.width, y: 0, width: bounds.width * 3, height: bounds.height)
    }

    func startAnimating() {
        let animation = CABasicAnimation(keyPath: "transform.translation.x")
        animation.fromValue = -bounds.width
        animation.toValue = bounds.width
        animation.duration = 1.4
        animation.repeatCount = .infinity
        gradientLayer.add(animation, forKey: "shimmerMove")
    }

    func stopAnimating() {
        gradientLayer.removeAllAnimations()
        removeFromSuperview()
    }
}

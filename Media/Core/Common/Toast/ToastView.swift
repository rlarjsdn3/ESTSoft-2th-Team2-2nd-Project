//
//  ToastView.swift
//  Media
//
//  Created by 강민지 on 6/10/25.
//

import UIKit

class ToastView: UIView {
    
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var iconImageView: UIImageView!
    
    @IBOutlet weak var messageLabel: UILabel!
    
    func configure(message: String, systemName: String?) {
        messageLabel.text = message
        
        containerView.layer.cornerRadius = 10
        containerView.layer.masksToBounds = true
        
        if let systemName = systemName {
            iconImageView.image = UIImage(systemName: systemName)
            iconImageView.tintColor = UIColor.backgroundColor
            iconImageView.isHidden = false
        } else {
            iconImageView.isHidden = true
        }
    }
}

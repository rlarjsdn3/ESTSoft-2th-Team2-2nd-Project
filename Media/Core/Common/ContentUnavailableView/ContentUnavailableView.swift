//
//  ContentUnavailableView.swift
//  Media
//
//  Created by 김건우 on 6/12/25.
//

import UIKit

final class ContentUnavailableView: NibView {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    @IBInspectable var imageName: String = "default" {
        didSet { imageView.image = UIImage(named: imageName) }
    }
    
    @IBInspectable var systemName: String = "sun.max" {
        didSet { imageView.image = UIImage(systemName: systemName)  }
    }
    
    @IBInspectable var title: String? {
        didSet { titleLabel.text = title }
    }
    
    @IBInspectable var subtitle: String? {
        didSet { subtitleLabel.text = subtitle }
    }
    
    @IBInspectable override var backgroundColor: UIColor? {
        didSet { self.backgroundColor = backgroundColor }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadFromNib(owner: self)
    }
}

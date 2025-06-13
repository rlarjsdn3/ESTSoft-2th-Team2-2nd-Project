//
//  ContentUnavailableView.swift
//  Media
//
//  Created by 김건우 on 6/12/25.
//

import UIKit

final class ContentUnavailableView: NibView {

    @IBOutlet weak var imageView: UIImageView!
    
    @IBInspectable var imageName: String = "no_bookmark" {
        didSet { imageView.image = UIImage(named: imageName) }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadFromNib(owner: self)
    }
}

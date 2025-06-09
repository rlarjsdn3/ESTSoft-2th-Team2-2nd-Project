//
//  CategoryCell.swift
//  Media
//
//  Created by Jaehun Kim on 6/9/25.
//

import UIKit

final class CategoryCell: UICollectionViewCell {


    @IBOutlet weak var titleButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        titleButton.layer.cornerRadius = 20
        titleButton.layer.masksToBounds = true
        titleButton.isUserInteractionEnabled = false
    }

    func configure(with title: String, selected: Bool) {
        titleButton.setTitle(title, for: .normal)

        if selected {
            titleButton.backgroundColor = UIColor(
                red: CGFloat(0x4C) / 255.0,
                green: CGFloat(0x5C) / 255.0,
                blue: CGFloat(0x5C) / 255.0,
                alpha: 1.0
            )
            titleButton.setTitleColor(.white, for: .normal)
        } else {
            titleButton.backgroundColor = UIColor(
                red: CGFloat(0xB0) / 255.0,
                green: CGFloat(0xB0) / 255.0,
                blue: CGFloat(0xB0) / 255.0,
                alpha: 1.0
            )
            titleButton.setTitleColor(.black, for: .normal)
        }

    }
}

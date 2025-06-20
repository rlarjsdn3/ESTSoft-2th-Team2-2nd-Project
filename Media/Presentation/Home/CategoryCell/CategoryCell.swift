//
//  CategoryCell.swift
//  Media
//
//  Created by Jaehun Kim on 6/9/25.
//

import UIKit

final class CategoryCell: UICollectionViewCell {


    @IBOutlet weak var titleButton: UIButton!

    override func layoutSubviews() {
        super.layoutSubviews()

        titleButton.layer.cornerRadius = self.frame.height / 2
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        titleButton.layer.masksToBounds = true
        titleButton.isUserInteractionEnabled = false
    }

    func configure(with title: String, selected: Bool) {
        titleButton.setTitle(title, for: .normal)

        if selected {
            titleButton.backgroundColor = .tagSelectedColor
            titleButton.setTitleColor(.backgroundColor, for: .normal)
            titleButton.layer.borderColor = UIColor.tagBorderColor.resolvedColor(with: traitCollection).cgColor
        } else {
            titleButton.backgroundColor = .tagUnselectedColor
            titleButton.setTitleColor(.mainLabelColor, for: .normal)
            titleButton.layer.borderColor = UIColor.tagBorderColor.resolvedColor(with: traitCollection).cgColor
        }
        titleButton.layer.borderWidth = 1.0

    }

//    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
//        titleButton.layer.borderColor = (previousTraitCollection?.userInterfaceStyle == .dark)
//        ? UIColor.black.cgColor
//        : UIColor.white.cgColor
//
//    }
}

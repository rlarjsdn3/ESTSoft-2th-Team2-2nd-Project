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
            titleButton.layer.borderColor = UIColor.tagBorderColor.cgColor
        } else {
            titleButton.backgroundColor = .tagUnselectedColor
            titleButton.setTitleColor(.mainLabelColor, for: .normal)
            titleButton.layer.borderColor = UIColor.tagBorderColor.cgColor
        }
        titleButton.layer.borderWidth = 2.0
    }
}

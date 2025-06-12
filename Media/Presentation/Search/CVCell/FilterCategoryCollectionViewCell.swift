//
//  CategoryCollectionViewCell.swift
//  Media
//
//  Created by 백현진 on 6/9/25.
//

import UIKit

class FilterCategoryCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var categoryContentView: UIView!
    @IBOutlet weak var categoryLabel: UILabel!

    func defaultCellConfigure() {
        categoryContentView.layer.cornerRadius = 12
        categoryContentView.backgroundColor = UIColor.tagUnselected
        categoryContentView.layer.borderWidth = 1.0
        categoryContentView.layer.borderColor = UIColor.tagBorder.cgColor
        categoryLabel.textColor = .black
    }

    func selectedCellConfigure() {
        categoryContentView.layer.cornerRadius = 12
        categoryContentView.backgroundColor = UIColor.tagSelected
        categoryContentView.layer.borderWidth = 1.0
        categoryContentView.layer.borderColor = UIColor.tagBorder.cgColor
        categoryLabel.textColor = .white
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if isSelected {
            categoryContentView.backgroundColor = UIColor.tagSelected
            categoryLabel.textColor = .white
        } else {
            categoryContentView.backgroundColor = UIColor.tagUnselected
            categoryLabel.textColor = .label
        }
    }
}

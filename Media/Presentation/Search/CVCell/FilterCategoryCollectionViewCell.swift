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

    // tagUnselected <-> Bolder Color가 바뀐듯
    func defaultCellConfigure() {
        categoryContentView.layer.cornerRadius = 12
        categoryContentView.backgroundColor = UIColor.tagBorder
        categoryContentView.layer.borderWidth = 1.0
        categoryContentView.layer.borderColor = UIColor.tagUnselected.cgColor
        categoryLabel.textColor = .black
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if isSelected {
            categoryContentView.backgroundColor = UIColor.tagSelected
            categoryLabel.textColor = .white
        } else {
            categoryContentView.backgroundColor = UIColor.tagBorder
            categoryLabel.textColor = .label
        }
    }
}

//
//  DateCollectionViewCell.swift
//  Media
//
//  Created by 백현진 on 6/9/25.
//

import UIKit

class FilterOrderCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var orderContentView: UIView!
    @IBOutlet weak var orderLabel: UILabel!

    func defaultCellConfigure() {
        orderContentView.layer.cornerRadius = 12
        orderContentView.backgroundColor = UIColor.tagUnselected
        orderContentView.layer.borderWidth = 1.0
        orderContentView.layer.borderColor = UIColor.tagBorder.cgColor
        orderLabel.textColor = .black
    }

    func selectedCellConfigure() {
        orderContentView.layer.cornerRadius = 12
        orderContentView.backgroundColor = UIColor.tagSelected
        orderContentView.layer.borderWidth = 1.0
        orderContentView.layer.borderColor = UIColor.tagBorder.cgColor
        orderLabel.textColor = .white
    }


    override func layoutSubviews() {
        super.layoutSubviews()

        if isSelected {
            orderContentView.backgroundColor = UIColor.tagSelected
            orderLabel.textColor = .systemBackground
        } else {
            orderContentView.backgroundColor = UIColor.tagUnselected
            orderLabel.textColor = .label
        }
    }
}

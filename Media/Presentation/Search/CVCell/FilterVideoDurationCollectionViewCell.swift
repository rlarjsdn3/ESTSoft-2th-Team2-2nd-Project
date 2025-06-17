//
//  FilterVideoLengthCollectionViewCell.swift
//  Media
//
//  Created by 백현진 on 6/9/25.
//

import UIKit

class FilterVideoDurationCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var durationContentView: UIView!
    @IBOutlet weak var durationLabel: UILabel!

    func defaultCellConfigure() {
        durationContentView.layer.cornerRadius = 12
        durationContentView.backgroundColor = UIColor.tagUnselected
        durationContentView.layer.borderWidth = 1.0
        durationContentView.layer.borderColor = UIColor.tagBorder.cgColor
        durationLabel.textColor = .black
    }

    func selectedCellConfigure() {
        durationContentView.layer.cornerRadius = 12
        durationContentView.backgroundColor = UIColor.tagSelected
        durationContentView.layer.borderWidth = 1.0
        durationContentView.layer.borderColor = UIColor.tagBorder.cgColor
        durationLabel.textColor = .white
    }


    override func layoutSubviews() {
        super.layoutSubviews()

        if isSelected {
            durationContentView.backgroundColor = UIColor.tagSelected
            durationLabel.textColor = .systemBackground
        } else {
            durationContentView.backgroundColor = UIColor.tagUnselected
            durationLabel.textColor = .label
        }
    }
}

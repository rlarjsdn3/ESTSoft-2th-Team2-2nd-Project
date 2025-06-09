//
//  DateCollectionViewCell.swift
//  Media
//
//  Created by 백현진 on 6/9/25.
//

import UIKit

class FilterDateCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var dateContentView: UIView!
    @IBOutlet weak var dateLabel: UILabel!

    func defaultCellConfigure() {
        dateContentView.layer.cornerRadius = 12
        dateContentView.backgroundColor = UIColor.tagUnselected
        dateContentView.layer.borderWidth = 1.0
        dateContentView.layer.borderColor = UIColor.tagBorder.cgColor
        dateLabel.textColor = .black
    }

    override var isSelected: Bool {
        didSet {
            if isSelected {
                dateContentView.backgroundColor = UIColor.tagSelected
                dateLabel.textColor = .white
            } else {
                dateContentView.backgroundColor = UIColor.tagUnselected
                dateLabel.textColor = .black
            }
        }
    }
}

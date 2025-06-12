//
//  OnboardingTegsViewCell.swift
//  Media
//
//  Created by 전광호 on 6/9/25.
//

import UIKit

class OnboardingTagsViewCell: UICollectionViewCell {
    
    @IBOutlet weak var tagsImageView: UIImageView!
    
    @IBOutlet weak var tagsTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.borderWidth = 1
        layer.borderColor = UIColor.primary.cgColor
        layer.cornerRadius = 20
        contentView.layer.borderColor = UIColor.primary.cgColor
        clipsToBounds = true
    }
}

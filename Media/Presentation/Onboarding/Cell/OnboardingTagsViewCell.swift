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

        layer.cornerRadius = 20
        clipsToBounds = true
        
        tagsTitle.minimumScaleFactor = 0.5
        tagsTitle.adjustsFontSizeToFitWidth = true
    }
}

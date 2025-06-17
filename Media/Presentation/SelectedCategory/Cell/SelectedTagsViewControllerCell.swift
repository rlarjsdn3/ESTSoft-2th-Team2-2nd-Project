//
//  TagsCell.swift
//  Media
//
//  Created by 전광호 on 6/10/25.
//

import UIKit

class SelectedTagsViewControllerCell: UICollectionViewCell {
    
    @IBOutlet weak var tagsImageView: UIImageView!
    
    @IBOutlet weak var tagsTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        tagsTitle.minimumScaleFactor = 0.5
        tagsTitle.adjustsFontSizeToFitWidth = true
    }
}

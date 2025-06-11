//
//  MediumVideoCell.swift
//  Media
//
//  Created by Heejung Yang on 6/10/25.
//

import UIKit

class MediumVideoCell: UICollectionViewCell {

    @IBOutlet weak var thumbnailImageView: UIImageView!

    @IBOutlet weak var tagsLabel: UILabel!

    @IBOutlet weak var userNameLabel: UILabel!

    @IBOutlet weak var viewsCountLabel: UILabel!

    @IBOutlet weak var actionButton: UIButton!

    @IBAction func tapButton(_ sender: Any) {
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    private func setViews() {
        thumbnailImageView.layer.borderWidth = 2
        thumbnailImageView.layer.borderColor = UIColor.white.cgColor
        thumbnailImageView.layer.cornerRadius = 8
    }

}

extension MediumVideoCell {
    func configure() {

    }
}

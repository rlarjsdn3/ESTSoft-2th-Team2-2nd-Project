//
//  MediumVideoCell.swift
//  Media
//
//  Created by Heejung Yang on 6/10/25.
//

import UIKit

class MediumVideoCell: UICollectionViewCell, NibLodable {

    @IBOutlet weak var thumbnailImageView: UIImageView!

    @IBOutlet weak var tagsLabel: UILabel!

    @IBOutlet weak var userNameLabel: UILabel!

    @IBOutlet weak var viewsCountLabel: UILabel!

    @IBOutlet weak var actionButton: UIButton!

    var dataTransferService: (any DataTransferService)?

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
    func configure(_ history: PlaybackHistoryEntity) {
        configureThumbnail(from: history.pageUrl)
        tagsLabel.text = history.tags
        userNameLabel.text = history.user
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        let result = numberFormatter.string(for: history.views)
        viewsCountLabel.text = result
    }

    private func configureThumbnail(from url: URL?) {
        if let url {
            let endpoint = APIEndpoints.thumbnail(url: url)
            dataTransferService?.request(endpoint) { [weak self] result in
                switch result {
                case .success(let data):
                    if let image = UIImage(data: data) {
                        self?.thumbnailImageView.image = image
                    } else {
                        // Placeholder
                        self?.thumbnailImageView.image = UIImage(named: "default")
                    }
                case .failure(let error):
                    print(error)
                    // Placeholder
                    self?.thumbnailImageView.image = UIImage(named: "default")
                }
            }
        } else {
            // placeholder
            thumbnailImageView.image = UIImage(named: "default")
        }
    }
}

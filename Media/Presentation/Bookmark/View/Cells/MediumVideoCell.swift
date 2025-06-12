//
//  MediumVideoCell.swift
//  Media
//
//  Created by Heejung Yang on 6/10/25.
//

import UIKit

class MediumVideoCell: UICollectionViewCell, NibLodable {

    @IBOutlet private weak var thumbnailImageView: UIImageView!

    @IBOutlet private weak var tagsLabel: UILabel!

    @IBOutlet private weak var userNameLabel: UILabel!

    @IBOutlet private weak var viewsCountLabel: UILabel!

    @IBOutlet private weak var actionButton: UIButton!

    @IBOutlet private weak var paddingLabel: UIView!

    @IBOutlet private weak var durationLabel: UILabel!

    /// 현재 셀에 로드 중인 썸네일 이미지의 URL입니다.
    private var currentThumbnailURL: URL?

    var isBookMark: Bool = false {
        didSet {
            actionButton
                .setImage(
                    isBookMark
                    ? UIImage(systemName: "bookmark.fill")
                    : UIImage(systemName: "bookmark.fill"),
                    for: .normal
                )

            actionButton.tintColor = isBookMark ? .label: .systemRed

        }
    }

    weak var delegate: MediumVideoButtonDelegate?

    @IBAction func buttonDidTap(_ sender: Any) {
        self.delegate?.deleteAction?(self)
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
        setViews()
    }

    private func setViews() {
        thumbnailImageView.layer.cornerRadius = 8
        paddingLabel.layer.cornerRadius = 3
    }

}

extension MediumVideoCell {
    func configure(_ history: MediumVideoViewModel) {
        currentThumbnailURL = history.thumbnailUrl
        configureThumbnail(from: history.thumbnailUrl)
        tagsLabel.text = history.tags
        userNameLabel.text = history.userName
        durationLabel.text = formatDuration(history.duration)
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        let result = numberFormatter.string(for: history.viewCount)
        viewsCountLabel.text = result
    }
    
    private func formatDuration(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }

    private func configureThumbnail(from url: URL?) {
        thumbnailImageView.backgroundColor = .systemGray6

        let session = URLSession.shared
        Task {
            if let url {
                let (data, _) = try await session.data(from: url)

                guard self.currentThumbnailURL == url else { return }

                thumbnailImageView.image = UIImage(data: data)
            } else {
                thumbnailImageView.image = UIImage(named: "default")
            }
        }
    }

}

struct MediumVideoViewModel {
    var tags: String
    var userName: String
    var viewCount: Int
    var duration: Int
    var thumbnailUrl: URL?
}

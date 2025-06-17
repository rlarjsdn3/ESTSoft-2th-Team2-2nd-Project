//
//  MediumVideoCell.swift
//  Media
//
//  Created by Heejung Yang on 6/10/25.
//

import UIKit

class MediumVideoCell: UICollectionViewCell, NibLodable, UIContextMenuInteractionDelegate {

    var previewProvider: UIContextMenuContentPreviewProvider?
    var actionProvider: UIContextMenuActionProvider?

    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(
                    identifier: nil,
                    previewProvider: previewProvider,
                    actionProvider: actionProvider
                )
    }
    
    @IBOutlet private weak var containerView: UIView!

    @IBOutlet private weak var thumbnailImageContainerView: UIView!
    
    /// 썸네일 이미지를 표시하는 뷰
    @IBOutlet private weak var thumbnailImageView: UIImageView!

    @IBOutlet private weak var timeProgressView: UIProgressView!
    /// 태그 정보를 표시하는 타이틀 라벨
    @IBOutlet private weak var tagsLabel: UILabel!

    /// 업로더 이름을 표시하는 라벨
    @IBOutlet private weak var userNameLabel: UILabel!

    /// 조회수를 표시하는 라벨
    @IBOutlet private weak var viewsCountLabel: UILabel!

    /// 북마크 혹은 삭제 버튼
    @IBOutlet private weak var actionButton: UIButton!

    /// 태그 라벨 뒤에 위치한 배경 뷰 (padding 목적)
    @IBOutlet private weak var paddingLabel: UIView!

    /// 비디오 길이를 표시하는 라벨
    @IBOutlet private weak var durationLabel: UILabel!

    /// 현재 셀에 로딩 중인 썸네일 이미지 URL (비동기 이미지 로드 중 중복 로딩 방지용)
    private var currentThumbnailURL: URL?

    /// 북마크 여부
    var isBookMark: Bool = false {
        didSet {
            let config = UIImage.SymbolConfiguration(pointSize: 12)
            let image = if isBookMark {
                UIImage(systemName: "bookmark.fill")?
                    .withConfiguration(config)
            } else {
                UIImage(systemName: "trash")?
                    .withConfiguration(config)
            }
            actionButton.setImage(image, for: .normal)
            actionButton.tintColor = isBookMark ? .label: .systemRed
        }
    }

    var isProgressHidden: Bool = false {
        didSet {
            timeProgressView.isHidden = isProgressHidden
        }
    }

    /// 셀 외부에서 버튼 액션을 처리할 수 있도록 하는 delegate
    weak var delegate: MediumVideoButtonDelegate?

    /// 버튼 탭 시 delegate에게 액션 전달
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

    override func prepareForReuse() {
        super.prepareForReuse()

        thumbnailImageView.stopShimmer()
        thumbnailImageView.image = nil
    }

    private func setViews() {
        thumbnailImageContainerView.layer.cornerRadius = 8
        paddingLabel.layer.cornerRadius = 3
        containerView.backgroundColor = .systemBackground
        containerView.layer.cornerRadius = 12
        containerView.layer.masksToBounds = true
    }

    func configureMenu(deleteAction: @escaping () -> Void) {
        let destruct = UIAction(title: "전체 삭제", image: UIImage(systemName: "trash"), attributes: .destructive) { _ in
            deleteAction()
        }
        let interaction = UIContextMenuInteraction(delegate: self)
        actionButton.addInteraction(interaction)
        actionProvider = { _ in
            UIMenu(title: "", children: [destruct])
        }
        actionButton.isContextMenuInteractionEnabled = true
    }

}

extension MediumVideoCell {
    func configure(_ history: MediumVideoViewModel) {
        thumbnailImageView.startShimmer()
        currentThumbnailURL = history.thumbnailUrl
        configureThumbnail(from: history.thumbnailUrl)
        tagsLabel.text = history.tags.split(by: ",").prefix(2).joined(separator: ", ")
        userNameLabel.text = history.userName
        durationLabel.text = formatDuration(history.duration)
        viewsCountLabel.text = formatViewCount(history.viewCount)
        guard let progress = history.progress else {
            timeProgressView.isHidden = true
            return
        }
        timeProgressView.setProgress(progress, animated: false)
    }

    private func formatViewCount(_ count: Int) -> String {
        if count >= 10_000 {
            let value = Double(count) / 10_000
            if abs(value.rounded() - value) < 0.1 {
                return "\(Int(value))M"
            } else {
                return String(format: "%.1fM", value)
            }
        } else if count >= 1_000 {
            let value = Double(count) / 1_000
            if abs(value.rounded() - value) < 0.1 {
                return "\(Int(value))K"
            } else {
                return String(format: "%.1fK", value)
            }
        } else {
            return "\(count)"
        }
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
                thumbnailImageView.stopShimmer()
            } else {
                thumbnailImageView.image = UIImage(named: "no_videos")
            }
        }
    }

}

struct MediumVideoViewModel {
    let tags: String
    let userName: String
    let viewCount: Int
    let duration: Int
    let thumbnailUrl: URL?
    let playTime: Double?
    
    var progress: Float? {
        guard let playTime = playTime, playTime > 0 else { return nil }
        return Float(playTime / Double(duration))
    }

    init(tags: String, userName: String, viewCount: Int, duration: Int, thumbnailUrl: URL?, playTime: Double? = nil) {
        self.tags = tags
        self.userName = userName
        self.viewCount = viewCount
        self.duration = duration
        self.thumbnailUrl = thumbnailUrl
        self.playTime = playTime
    }
}

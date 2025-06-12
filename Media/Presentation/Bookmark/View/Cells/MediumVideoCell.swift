//
//  MediumVideoCell.swift
//  Media
//
//  Created by Heejung Yang on 6/10/25.
//

import UIKit

class MediumVideoCell: UICollectionViewCell, NibLodable {

    /// 썸네일 이미지를 표시하는 뷰
    @IBOutlet private weak var thumbnailImageView: UIImageView!

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

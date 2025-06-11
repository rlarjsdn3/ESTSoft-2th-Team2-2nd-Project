//
//  SmallVideoCell.swift
//  Media
//
//  Created by Heejung Yang on 6/9/25.
//

import UIKit

final class SmallVideoCell: UICollectionViewCell, NibLodable {

    /// 썸네일 이미지를 표시하는 이미지 뷰
    @IBOutlet weak var thumbnailImageView: UIImageView!

    /// 썸네일에 그림자를 줄 때 사용하는 뷰 (목록임을 나타내는 이미지)
    @IBOutlet weak var shadowView: UIView!

    /// 동영상 재생목록 타이틀을 표시하는 라벨
    @IBOutlet weak var titleLabel: UILabel!

    /// 마지막 셀에 표시될 플러스 버튼 (새 항목 추가용)
    @IBOutlet weak var plusImageView: UIImageView!

    @IBOutlet weak var videoCountBackgroundView: UIStackView!

    @IBOutlet weak var videoCountLabel: UILabel!
    
    var dataTransferService: (any DataTransferService)?

    var isLast: Bool = false {
        didSet {
            plusImageView.isHidden = !isLast
            thumbnailImageView.isHidden = isLast
            shadowView.isHidden = isLast
            titleLabel.textAlignment = isLast ? .center : .left
            videoCountBackgroundView.isHidden = isLast
            if isLast { titleLabel.text = "재생목록 추가"}
        }
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
        plusImageView.layer.cornerRadius = plusImageView.frame.height/2
        thumbnailImageView.layer.borderWidth = 2
        thumbnailImageView.layer.borderColor = UIColor.white.cgColor
        thumbnailImageView.layer.cornerRadius = 8
        shadowView.layer.cornerRadius = 8
        videoCountBackgroundView.layer.cornerRadius = 3
        videoCountBackgroundView.isLayoutMarginsRelativeArrangement = true
        videoCountBackgroundView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 3, leading: 5, bottom: 3, trailing: 5)
    }

}

extension SmallVideoCell {
    /// 셀의 내용을 구성하는 메서드
    /// - Parameters:
    ///   - url: 썸네일 이미지의 URL (nil이면 기본 이미지 사용)
    ///   - title: 동영상 제목
    ///   - isLast: 마지막 셀인지 여부 (true면 플러스 버튼 표시)
    func configure(
        url: URL? = nil,
        title: String,
        isLast: Bool = false
    ) {
        titleLabel.text = title
        self.isLast = isLast
        configureThumbnail(from: url)
    }

    func configure(_ playlist: PlaylistEntity) {
        guard let playlistVideoEntity = (playlist.playlistVideos?.allObjects.first as? PlaylistVideoEntity),
              let thumbnailUrl = playlistVideoEntity.video?.medium.thumbnail,
              let playlistName = playlistVideoEntity.playlist?.name else { return }
        isLast = false
        titleLabel.text = playlistName
        configureThumbnail(from: thumbnailUrl)
        configureVideoCount(playlist.playlistVideos?.allObjects.count ?? 0)
    }

    private func configureThumbnail(from url: URL?) {
        thumbnailImageView.backgroundColor = .systemGray6

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

    func configureVideoCount(_ count: Int) {
        videoCountLabel.text = "\(count)"
    }
}

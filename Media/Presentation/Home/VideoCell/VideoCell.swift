//
//  VideoCell.swift
//  Media
//
//  Created by Jaehun Kim on 6/9/25.
//

import UIKit

final class VideoCell: UICollectionViewCell {

    @IBOutlet weak var thumbnailImage: UIImageView!

    @IBOutlet weak var profileImage: UIImageView!

    @IBOutlet weak var titleLabel: UILabel!

    @IBOutlet weak var viewCountLabel: UILabel!

    @IBOutlet weak var durationLabel: UILabel!

    @IBOutlet weak var ellipsisButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        thumbnailImage.contentMode = .scaleAspectFit
        thumbnailImage.clipsToBounds = true

        profileImage.contentMode = .scaleAspectFill
        profileImage.clipsToBounds = true

        titleLabel.textColor = .mainLabelColor
        titleLabel.backgroundColor = .backgroundColor

        viewCountLabel.textColor = .subLabelColor
        viewCountLabel.backgroundColor = .backgroundColor

        durationLabel.textColor = .subLabelColor
        durationLabel.backgroundColor = .backgroundColor
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        profileImage.layer.cornerRadius = profileImage.frame.size.width / 2
    }


    override func prepareForReuse() {
        super.prepareForReuse()

        thumbnailImage.image = nil
        profileImage.image = nil
    }

    // 셀을 PixabayResponse.Hit 데이터로 구성합니다
    // Parameter hit : Pixabay에서 받아온 비디오 데이터 모델
    func configure(with hit: PixabayResponse.Hit) {
        // 사용자 이름 제목 레이블 표시
        titleLabel.text = hit.user
        // 조회 수 텍스트 설정
        viewCountLabel.text = "Views: \(hit.views)"
        // 영상 길이를 형식화해서 레이블설정( 00:00 )
        durationLabel.text = formatDuration(seconds: hit.duration)
        // 썸네일 이미지 로딩 ( URL이 있을경우 )
        if let thumbnailURL = hit.videos.medium.thumbnail {
            loadImage(from: thumbnailURL, into: thumbnailImage)
        } else {
            // (없을경우)
            thumbnailImage.image = nil
        }
        // 프로필 이미지 로딩
        loadImage(from: hit.userImageUrl, into: profileImage)
    }

    private func formatDuration(seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }

    private func loadImage(from url: URL, into imageView: UIImageView) {
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url),
               let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    imageView.image = image
                }
            }
        }
    }
}


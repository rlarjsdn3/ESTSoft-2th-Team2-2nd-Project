//
//  SmallVideoCell.swift
//  Media
//
//  Created by Heejung Yang on 6/9/25.
//

import UIKit

final class SmallVideoCell: UICollectionViewCell {

    /// 썸네일 이미지를 표시하는 이미지 뷰
    @IBOutlet weak var thumbnailImageView: UIImageView!

    /// 썸네일에 그림자를 줄 때 사용하는 뷰 (목록임을 나타내는 이미지)
    @IBOutlet weak var shadowView: UIView!

    /// 동영상 재생목록 타이틀을 표시하는 라벨
    @IBOutlet weak var titleLabel: UILabel!

    /// 마지막 셀에 표시될 플러스 버튼 (새 항목 추가용)
    @IBOutlet weak var plusButton: UIButton!

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
        thumbnailImageView.layer.borderWidth = 2
        thumbnailImageView.layer.borderColor = UIColor.white.cgColor
        thumbnailImageView.layer.cornerRadius = 8
        shadowView.layer.cornerRadius = 8
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

        guard !isLast else {
            thumbnailImageView.isHidden = true
            shadowView.isHidden = true
            return
        }

        plusButton.isHidden = true
        thumbnailImageView.backgroundColor = .systemGray6

        let session = URLSession.shared
        if let url {
            Task {
                let (data, _) = try await session.data(from: url)
                thumbnailImageView.image = UIImage(data: data)
            }
        } else {
            thumbnailImageView.image = UIImage(named: "default")
        }
    }
}

//
//  SmallVideoCell.swift
//  Media
//
//  Created by Heejung Yang on 6/9/25.
//

import UIKit

/// 재생목록의 썸네일을 보여주는 셀.
/// 마지막 셀일 경우 "재생목록 추가" UI를 표시합니다.
final class SmallVideoCell: UICollectionViewCell, NibLodable {

    var onEditAction: (() -> Void)?
    var onDeleteAction: (() -> Void)?

    /// 썸네일 이미지를 표시하는 이미지 뷰
    @IBOutlet private weak var thumbnailImageView: UIImageView!

    /// 썸네일에 그림자를 줄 때 사용하는 뷰 (목록임을 나타내는 이미지)
    @IBOutlet private weak var shadowView: UIView!

    @IBOutlet weak var fileContainerView: UIView!

    /// 동영상 재생목록 타이틀을 표시하는 라벨
    @IBOutlet private weak var titleLabel: UILabel!

    /// 마지막 셀에만 표시되는 '+' 아이콘 이미지 뷰
    @IBOutlet private weak var plusImageView: UIImageView!

    /// 비디오 개수 뷰의 배경이 되는 스택 뷰
    @IBOutlet weak var videoCountBackgroundView: UIStackView!

    /// 재생목록에 포함된 비디오 개수 라벨
    @IBOutlet weak var videoCountLabel: UILabel!

    /// 마지막 셀인지 여부를 나타내는 플래그
    var isLast: Bool = false {
        didSet {
            // 마지막 셀일 경우 '+' 버튼을 보여주고 일반 셀 UI는 숨김 처리
            plusImageView.isHidden = !isLast
            thumbnailImageView.isHidden = isLast
            shadowView.isHidden = isLast
            titleLabel.textAlignment = isLast ? .center : .left
            videoCountBackgroundView.isHidden = isLast
            if isLast { titleLabel.text = "재생목록 추가"}
            fileContainerView.isUserInteractionEnabled = !isLast
        }
    }

    var isBookMark: Bool = false {
        didSet {
            fileContainerView.isUserInteractionEnabled = !isBookMark
        }
    }

    /// 현재 셀에 로드 중인 썸네일 이미지의 URL입니다.
    private var currentThumbnailURL: URL?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        setViews()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        setViews()
    }

    private func setViews() {
        setupLayout()
        setupContextMenu()
    }

    private func setupLayout() {
        plusImageView.layer.cornerRadius = plusImageView.frame.height/2
        thumbnailImageView.layer.borderWidth = 2
        thumbnailImageView.layer.borderColor = UIColor.background.resolvedColor(with: traitCollection).cgColor
        thumbnailImageView.layer.cornerRadius = 8
        shadowView.layer.cornerRadius = 8
        videoCountBackgroundView.layer.cornerRadius = 3
        videoCountBackgroundView.isLayoutMarginsRelativeArrangement = true
        videoCountBackgroundView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 3, leading: 5, bottom: 3, trailing: 5)
    }

    private func setupContextMenu() {
        let interaction = UIContextMenuInteraction(delegate: self)
        fileContainerView.addInteraction(interaction)
    }
}

extension SmallVideoCell {
    /// 셀을 외부에서 구성할 때 사용하는 기본 설정 메서드
      /// - Parameters:
      ///   - url: 썸네일 이미지 URL
      ///   - title: 재생목록 제목
      ///   - isLast: 마지막 셀 여부
    func configure(
        url: URL? = nil,
        title: String,
        isLast: Bool = false
    ) {
        currentThumbnailURL = url
        titleLabel.text = title
        self.isLast = isLast
        configureThumbnail(from: url)
    }

    func configure(_ playlist: PlayListViewModel) {
        isLast = false
        currentThumbnailURL = playlist.thumbnailUrl
        titleLabel.text = playlist.userName
        videoCountLabel.text = "\(playlist.total ?? 0)"
        configureThumbnail(from: playlist.thumbnailUrl)
    }

    private func configureThumbnail(from url: URL?) {
        thumbnailImageView.backgroundColor = .systemGray4

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

extension SmallVideoCell: UIContextMenuInteractionDelegate {

    func contextMenuInteraction(
        _ interaction: UIContextMenuInteraction,
        configurationForMenuAtLocation location: CGPoint
    ) -> UIContextMenuConfiguration? {

        return UIContextMenuConfiguration(
            identifier: nil,
            previewProvider: nil
        ) { suggestedActions in

            // 메뉴 항목 생성
            let edit = UIAction(
                title: "Rename Playlist",
                image: UIImage(systemName: "square.and.pencil")
            ) { action in
                self.onEditAction?()
            }
            let delete = UIAction(
                title: "Delete Playlist",
                image: UIImage(systemName: "trash"),
                attributes: .destructive
            ) { action in
                self.onDeleteAction?()
            }
            return UIMenu(title: "", children: [edit, delete])
        }
    }
}


struct PlayListViewModel {
    var thumbnailUrl: URL?
    var userName: String?
    var total: Int?
}


import UIKit

final class VideoCell: UICollectionViewCell, NibLodable {

    var video: PixabayResponse.Hit?

    @IBOutlet weak var thumbnailImage: UIImageView!

    @IBOutlet weak var profileImage: UIImageView!

    @IBOutlet weak var titleLabel: UILabel!

    @IBOutlet weak var viewCountLabel: UILabel!

    @IBOutlet weak var durationLabel: UILabel!

    @IBOutlet weak var ellipsisButton: UIButton!

    @IBOutlet weak var likeCountLabel: UILabel!

    @IBOutlet weak var viewIcon: UIImageView!

    @IBOutlet weak var tagLabel: UILabel!

    @IBOutlet weak var likeIcon: UIImageView!

    private var currentImageURL: URL?
    private var currentProfileURL: URL?

    @IBAction func ellipsisButtonAction(_ sender: Any) {

    }

    var onThumbnailTap: (() -> Void)?

    var onTagTap: ((String) -> Void)?

    // Scroll To Item
    @objc private func tagTapped() {
        guard let tagText = tagLabel.text else { return }

        onTagTap?(tagText)
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        thumbnailImage.contentMode = .scaleAspectFill
        thumbnailImage.layer.cornerRadius = 8
        thumbnailImage.clipsToBounds = true

        profileImage.contentMode = .scaleAspectFill
        profileImage.clipsToBounds = true

        titleLabel.textColor = .mainLabelColor
        titleLabel.backgroundColor = .backgroundColor

        viewCountLabel.textColor = .subLabelColor
        viewCountLabel.backgroundColor = .backgroundColor

        durationLabel.textColor = .background
        durationLabel.backgroundColor = .tagSelectedColor
        durationLabel.layer.cornerRadius = 3
        durationLabel.clipsToBounds = true

        likeCountLabel.textColor = .subLabelColor
        likeCountLabel.backgroundColor = .backgroundColor

        tagLabel.textColor = .background
        tagLabel.backgroundColor = .tagSelectedColor
        tagLabel.layer.cornerRadius = 3
        tagLabel.clipsToBounds = true

        thumbnailImage.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(thumbnailTapped))
        thumbnailImage.addGestureRecognizer(tapGesture)
        
        ellipsisButton.showsMenuAsPrimaryAction = true

        tagLabel.isUserInteractionEnabled = true
        let tagTapGesture = UITapGestureRecognizer(target: self, action: #selector(tagTapped))
        tagLabel.addGestureRecognizer(tagTapGesture)
    }

    @objc private func thumbnailTapped() {
        onThumbnailTap?()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        profileImage.layer.cornerRadius = profileImage.frame.size.width / 2
    }


    override func prepareForReuse() {
        super.prepareForReuse()

        thumbnailImage.stopShimmeringOverlay()
        thumbnailImage.image = nil
        profileImage.image = nil

        titleLabel.text = nil
        viewCountLabel.text = nil
    }

    // Ellipsis 버튼 함수
    func configureMenu(bookmarkAction: @escaping () -> Void, playlistAction: @escaping () -> Void) {

        let bookmark = UIAction(title: "Add to Bookmark", image: UIImage(systemName: "bookmark")) { _ in
            bookmarkAction()

        }

        let playlist = UIAction(title: "Add to Playlists", image: UIImage(systemName: "list.bullet")) { _ in
            playlistAction()

        }

        let menu = UIMenu(title: "", children: [bookmark, playlist])
        ellipsisButton.menu = menu
        ellipsisButton.showsMenuAsPrimaryAction = true
    }

    /// 점 세 개 버튼(ellipsisButton)에 삭제 메뉴를 구성합니다.
    /// - Parameter onDeleteAction: 사용자가 "Delete Playback History" 항목을 선택했을 때 실행될 클로저입니다.
    func configureMenu(onDeleteAction: @escaping UIActionHandler) {
        let deleteAction = UIAction(
            title: "Delete Playback History",
            image: UIImage(systemName: "trash"),
            attributes: .destructive,
            handler: onDeleteAction
        )

        ellipsisButton.menu = UIMenu(title: "", children: [deleteAction])
    }

    // 뷰 모델을 받아 셀의 UI를 업데이트하는 함수
    // Parameter viewModel: VideoCellViewModel 타입의 데이터
    func configure(with viewModel: VideoCellViewModel) {
        titleLabel.text = viewModel.title
        viewCountLabel.text = viewModel.viewCountText
        durationLabel.text = viewModel.durationText
        likeCountLabel.text = viewModel.likeCountText
        tagLabel.text = viewModel.categoryText

        currentImageURL = viewModel.thumbnailURL

        thumbnailImage.startShimmeringOverlay()

        if let thumbURL = viewModel.thumbnailURL {
                    loadImage(
                        from: thumbURL,
                        into: thumbnailImage,
                        compareWith: \.currentImageURL
                    )
                } else {
                    thumbnailImage.stopShimmeringOverlay()
                    thumbnailImage.image = UIImage(named: "no_videos")
                }
                currentProfileURL = viewModel.profileImageURL
                if let profURL = viewModel.profileImageURL {
                    loadImage(
                        from: profURL,
                        into: profileImage,
                        compareWith: \.currentProfileURL
                    )
                } else {
                    profileImage.image = UIImage(named: "no_profile")
                }

        self.setNeedsLayout()
        self.layoutIfNeeded()
            }

    private func loadImage(from url: URL, into imageView: UIImageView, compareWith holderKeyPath: KeyPath<VideoCell, URL?>) {
        DispatchQueue.global(qos: .background).async { [weak imageView] in
            guard let data = try? Data(contentsOf: url),
                  let image = UIImage(data: data) else { return }

            DispatchQueue.main.async {
                guard let imageView = imageView else { return }
                guard self[keyPath: holderKeyPath] == url else { return }
                imageView.image = image
                imageView.stopShimmeringOverlay()
            }
        }
    }

    func setThumbnailImageCornerRadius(_ radius: CGFloat) {
        thumbnailImage.layer.cornerRadius = radius
        thumbnailImage.layer.masksToBounds = true
    }

    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)

    }
}


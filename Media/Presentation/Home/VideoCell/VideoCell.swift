
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

    @IBAction func ellipsisButtonAction(_ sender: Any) {

    }

    var onThumbnailTap: (() -> Void)?

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

        durationLabel.textColor = .white
        durationLabel.backgroundColor = .tagSelectedColor
        durationLabel.layer.cornerRadius = 3
        durationLabel.clipsToBounds = true

        likeCountLabel.textColor = .subLabelColor
        likeCountLabel.backgroundColor = .backgroundColor

        tagLabel.textColor = .white
        tagLabel.backgroundColor = .tagSelectedColor
        tagLabel.layer.cornerRadius = 3
        tagLabel.clipsToBounds = true

        thumbnailImage.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(thumbnailTapped))
        thumbnailImage.addGestureRecognizer(tapGesture)
        
        ellipsisButton.showsMenuAsPrimaryAction = true
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

        if let thumbnailURL = viewModel.thumbnailURL {
            loadImage(from: thumbnailURL, into: thumbnailImage)
        } else {
            thumbnailImage.image = UIImage(named: "no_videos")
        }
        if let profileURL = viewModel.profileImageURL {
            loadImage(from: profileURL, into: profileImage)
        } else {
            profileImage.image = nil
        }

        self.setNeedsLayout()
        self.layoutIfNeeded()
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

    func setThumbnailImageCornerRadius(_ radius: CGFloat) {
        thumbnailImage.layer.cornerRadius = radius
        thumbnailImage.layer.masksToBounds = true
    }
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        print("📐 VideoCell.apply() - \(layoutAttributes.frame)")
    }
}


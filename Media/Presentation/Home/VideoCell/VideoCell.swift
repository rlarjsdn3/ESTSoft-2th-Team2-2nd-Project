
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

    // 뷰 모델을 받아 셀의 UI를 업데이트하는 함수
    // Parameter viewModel: VideoCellViewModel 타입의 데이터
    func configure(with viewModel: VideoCellViewModel) {
        titleLabel.text = viewModel.title
        viewCountLabel.text = viewModel.viewCountText
        durationLabel.text = viewModel.durationText

        if let thumbnailURL = viewModel.thumbnailURL {
            loadImage(from: thumbnailURL, into: thumbnailImage)
        } else {
            thumbnailImage.image = nil
        }
        if let profileURL = viewModel.profileImageURL {
            loadImage(from: profileURL, into: profileImage)
        } else {
            profileImage.image = nil
        }
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


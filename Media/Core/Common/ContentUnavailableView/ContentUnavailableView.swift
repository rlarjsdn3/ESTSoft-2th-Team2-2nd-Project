//
//  ContentUnavailableView.swift
//  Media
//
//  Created by 김건우 on 6/12/25.
//

import UIKit

final class ContentUnavailableView: NibView {
    
    /// 사용자에게 콘텐츠가 없음을 나타내는 이미지를 표시하는 뷰입니다.
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var imageWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!

    /// 표시할 이미지 리소스를 나타내는 속성입니다.
    /// 설정 시 자동으로 `imageView`의 이미지를 업데이트합니다.
    var imageResource: ImageResource = .noVideos {
        didSet { imageView.image = UIImage(resource: imageResource) }
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadFromNib(owner: self)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let viewWidth = self.bounds.width
        let viewHeight = self.bounds.height

        if traitCollection.horizontalSizeClass == .compact {
            imageWidthConstraint.constant = viewWidth * 0.75
            imageHeightConstraint.constant = viewHeight * 0.75
        } else {
            imageWidthConstraint.constant = viewWidth * 0.5
            imageHeightConstraint.constant = viewHeight * 0.5

        }
    }
}

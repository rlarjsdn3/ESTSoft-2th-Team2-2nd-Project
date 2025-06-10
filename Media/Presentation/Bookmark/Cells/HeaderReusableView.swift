//
//  HeaderReusableView.swift
//  Media
//
//  Created by Heejung Yang on 6/10/25.
//

import UIKit

/// 재생기록 섹션 헤더에 사용되는 커스텀 뷰
class HeaderReusableView: UICollectionReusableView {

    /// 헤더의 타이틀을 표시하는 라벨
    @IBOutlet weak var titleLabel: UILabel!

    /// 버튼에 표시될 라벨
    @IBOutlet weak var buttonTitleLabel: UILabel!

    /// 헤더 우측의 버튼
    @IBOutlet weak var button: UIButton!

    /// 버튼 탭 이벤트를 처리할 delegate
    weak var delegate: HeaderButtonDelegate?

    /// 버튼이 탭되었을 때 호출되는 액션 메서드
    @IBAction func tapButton(_ sender: Any) {
        delegate?.HeaderButtonDidTap?(self)
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
    }
    
}

extension HeaderReusableView {
    /// 뷰의 콘텐츠를 구성하는 메서드
    /// - Parameters:
    ///   - title: 헤더에 표시할 제목
    ///   - hasEvent: 버튼을 표시할지 여부 (기본값은 false)
    func configure(
        title: String,
        hasEvent: Bool = false,
    ) {
        titleLabel.text = title
        guard !hasEvent else {
            return
        }
        button.isHidden = true
        buttonTitleLabel.isHidden = true
    }
}

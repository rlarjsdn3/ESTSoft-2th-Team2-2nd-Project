//
//  NavigationBar.swift
//  Media
//
//  Created by 강민지 on 6/8/25.
//

import UIKit

class NavigationBar: NibView {
    @IBOutlet var view: UIView!
        
    @IBOutlet weak var centerContainerView: UIView!
    @IBOutlet weak var titleStackView: UIStackView!
    @IBOutlet weak var searchBarContainerView: UIView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    
    weak var delegate: NavigationBarDelegate?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadFromNib(owner: self)
    }
    
    override var intrinsicContentSize: CGSize {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return CGSize(width: UIView.noIntrinsicMetric, height: 60)
        } else {
            return CGSize(width: UIView.noIntrinsicMetric, height: 44)
        }
        return CGSize(width: UIView.noIntrinsicMetric, height: height)
    }
    
    func configure(
        title: String,
        subtitle: String = "",
        titleColor: UIColor = UIColor.mainLabelColor,
        subtitleColor: UIColor = UIColor.subLabelColor,
        backgroundColor: UIColor = UIColor.backgroundColor,
        leftIcon: UIImage? = nil,
        leftIconTint: UIColor = UIColor.mainLabelColor,
        rightIcon: UIImage? = nil,
        rightIconTint: UIColor = UIColor.mainLabelColor,
        isSearchMode: Bool = false,
        isLeadingAligned: Bool = false,
        searchPlaceholder: String = "Search"
    ) {
        // 배경 설정
        view.backgroundColor = backgroundColor

        // 버튼 설정
        leftButton.setImage(leftIcon, for: .normal)
        rightButton.setImage(rightIcon, for: .normal)
        
        leftButton.tintColor = leftIconTint
        rightButton.tintColor = rightIconTint
        
        leftButton.isHidden = (leftIcon == nil)
        rightButton.isHidden = (rightIcon == nil)
        
        // 모드 1 - 검색 모드
        if isSearchMode {
            searchBarContainerView.isHidden = false
            titleStackView.isHidden = true
            
            searchBar.placeholder = searchPlaceholder
            searchBar.backgroundColor = .clear
            searchBar.barTintColor = .clear
            searchBar.backgroundImage = UIImage()
            searchBar.searchTextField.backgroundColor = UIColor.searchBarBackgroundColor
            
            return
        }

        // 모드 2 - 텍스트 모드
        searchBarContainerView.isHidden = true
        titleStackView.isHidden = false
        
        // 타이틀/서브타이틀 설정
        titleLabel.text = title
        titleLabel.textColor = titleColor
        subtitleLabel.text = subtitle
        subtitleLabel.textColor = subtitleColor
        subtitleLabel.isHidden = subtitle.isEmpty
        
        // 서브타이틀 유무에 따라 폰트/레이아웃 조정
        if subtitle.isEmpty {
            // 서브타이틀 없음
            subtitleLabel.isHidden = true
            titleLabel.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        } else {
            // 서브타이틀 있음
            subtitleLabel.isHidden = false
            titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
            subtitleLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        }
        
        // 라벨 정렬 방식
        titleStackView.alignment = isLeadingAligned ? .leading : .center
        titleLabel.textAlignment = isLeadingAligned ? .left : .center
        subtitleLabel.textAlignment = isLeadingAligned ? .left : .center
    }
    
    @IBAction func leftTapped(_ sender: Any) {
        delegate?.navigationBarDidTapLeft(self)
    }
    
    @IBAction func rightTapped(_ sender: Any) {
        delegate?.navigationBarDidTapRight(self)
    }
}

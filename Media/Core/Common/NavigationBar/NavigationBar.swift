//
//  NavigationBar.swift
//  Media
//
//  Created by 강민지 on 6/8/25.
//

import UIKit

/// 커스텀 네비게이션 바 뷰 클래스
/// NibView를 상속받아 XIB 기반으로 구성되며, 타이틀/서브타이틀/검색바 모드를 지원함
class NavigationBar: NibView {
    /// 전체 View (Nib로부터 불러올 때 사용)
    @IBOutlet var view: UIView!
        
    /// 타이틀 및 서브타이틀을 포함하는 컨테이너 뷰
    @IBOutlet weak var centerContainerView: UIView!
    
    /// 타이틀과 서브타이틀을 담는 StackView
    @IBOutlet weak var titleStackView: UIStackView!
    
    /// 검색바가 표시되는 뷰
    @IBOutlet weak var searchBarContainerView: UIView!
    
    /// 메인 타이틀 라벨
    @IBOutlet weak var titleLabel: UILabel!
    
    /// 서브 타이틀 라벨
    @IBOutlet weak var subtitleLabel: UILabel!
    
    /// 왼쪽 버튼 (예: 뒤로가기)
    @IBOutlet weak var leftButton: UIButton!
    
    /// 오른쪽 버튼 (예: 검색, 필터링)
    @IBOutlet weak var rightButton: UIButton!
    
    /// 검색바
    @IBOutlet weak var searchBar: UISearchBar!
    
    // MARK: - Delegate
    /// 버튼 탭 이벤트를 위임받기 위한 델리게이트
    weak var delegate: NavigationBarDelegate?
    
    // MARK: - Initializer
    /// Interface Builder에서 초기화될 때 호출
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadFromNib(owner: self)
        setupButtonActions()
    }
    
    // MARK: - Setup
    /// 버튼 액션을 코드로 연결
    private func setupButtonActions() {
        leftButton.addTarget(self, action: #selector(leftTapped(_:)), for: .touchUpInside)
        rightButton.addTarget(self, action: #selector(rightTapped(_:)), for: .touchUpInside)
    }
    
    // MARK: - Configuration
    /**
     네비게이션 바를 구성합니다

     - Parameters:
       - title: 타이틀 텍스트
       - subtitle: 서브타이틀 텍스트
       - titleColor: 타이틀 텍스트 색상
       - subtitleColor: 서브타이틀 텍스트 색상
       - backgroundColor: 전체 배경색
       - leftIcon: 왼쪽 버튼 아이콘 이미지
       - leftIconTint: 왼쪽 버튼 아이콘 색상
       - rightIcon: 오른쪽 버튼 아이콘 이미지
       - rightIconTint: 오른쪽 버튼 아이콘 색상
       - isSearchMode: 검색 모드 여부 (true일 경우 검색바 표시)
       - isLeadingAligned: 라벨 및 텍스트 좌측 정렬 여부
       - searchPlaceholder: 검색바 플레이스홀더
     */
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
        // 배경색 설정
        view.backgroundColor = backgroundColor

        // 버튼 아이콘 및 색상 설정
        leftButton.setImage(leftIcon, for: .normal)
        rightButton.setImage(rightIcon, for: .normal)
        
        leftButton.tintColor = leftIconTint
        rightButton.tintColor = rightIconTint
        
        // 검색 모드인 경우
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

        leftButton.isHidden = (leftIcon == nil)
        rightButton.isHidden = (rightIcon == nil)
        
        // 타이틀 모드인 경우
        searchBarContainerView.isHidden = true
        titleStackView.isHidden = false
        
        // 타이틀/서브타이틀 설정
        titleLabel.text = title
        titleLabel.textColor = titleColor
        subtitleLabel.text = subtitle
        subtitleLabel.textColor = subtitleColor
        subtitleLabel.isHidden = subtitle.isEmpty
        
        // 서브타이틀 유무에 따라 폰트 설정
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
        
        // 라벨 및 텍스트 정렬 방식 설정
        titleStackView.alignment = isLeadingAligned ? .leading : .center
        titleLabel.textAlignment = isLeadingAligned ? .left : .center
        subtitleLabel.textAlignment = isLeadingAligned ? .left : .center
    }
    
    // MARK: - Button Actions
    
    /// 왼쪽 버튼이 눌렸을 때 delegate에 이벤트 전달
    @objc private func leftTapped(_ sender: Any) {
        delegate?.navigationBarDidTapLeft?(self)
    }
    
    /// 오른쪽 버튼이 눌렸을 때 delegate에 이벤트 전달
    @objc private func rightTapped(_ sender: Any) {
        delegate?.navigationBarDidTapRight?(self)
    }
}

extension NavigationBar {
    /// 오른쪽 버튼을 시각적으로 숨기고 터치 이벤트를 비활성화
    func hideRightButton() {
        rightButton.alpha = 0
        rightButton.isUserInteractionEnabled = false
    }
    
    /// 오른쪽 버튼을 다시 보이게 하고 터치 이벤트를 활성화
    func showRightButton() {
        rightButton.alpha = 1
        rightButton.isUserInteractionEnabled = true
    }
    
    /// 왼쪽 버튼을 시각적으로 숨기고 터치 이벤트를 비활성화
    func hideLeftButton() {
        leftButton.alpha = 0
        leftButton.isUserInteractionEnabled = false
    }
    
    /// 왼쪽 버튼을 다시 보이게 하고 터치 이벤트를 활성화
    func showLeftButton() {
        leftButton.alpha = 1
        leftButton.isUserInteractionEnabled = true
    }
}

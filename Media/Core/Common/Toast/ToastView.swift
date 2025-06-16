//
//  ToastView.swift
//  Media
//
//  Created by 강민지 on 6/10/25.
//

import UIKit

/// XIB 기반의 커스텀 Toast 뷰 클래스.
/// 내부 구성 요소: 컨테이너 뷰, 아이콘 이미지 뷰, 메시지 라벨
class ToastView: UIView {
    /// 둥근 배경을 위한 컨테이너 뷰
    @IBOutlet weak var containerView: UIView!
    /// 메시지 앞에 표시될 아이콘 뷰 (옵션)
    @IBOutlet weak var iconImageView: UIImageView!
    /// 토스트 메시지 라벨
    @IBOutlet weak var messageLabel: UILabel!
    
    /// 토스트 뷰의 내용을 설정합니다
       /// - Parameters:
       ///   - message: 표시할 텍스트
       ///   - systemName: SF Symbol 아이콘 이름 (nil이면 아이콘 숨김)
    func configure(message: String, systemName: String?) {
        messageLabel.text = message
        
        // 스타일 설정
        self.backgroundColor = .clear
        containerView.layer.cornerRadius = 10
        containerView.layer.masksToBounds = true
        
        if let systemName = systemName {
            iconImageView.image = UIImage(systemName: systemName)
            iconImageView.tintColor = UIColor.backgroundColor
            iconImageView.isHidden = false
        } else {
            iconImageView.isHidden = true
        }
    }
    
    deinit {
        print("ToastView도 해제됨")
    }
}

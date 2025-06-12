//
//  PlaylistDelegate.swift
//  Media
//
//  Created by Heejung Yang on 6/10/25.
//

import UIKit

/// 컬렉션 뷰의 헤더에서 버튼 액션이 발생했을 때 delegate에게 이벤트를 전달하는 프로토콜
@objc protocol HeaderButtonDelegate: NSObjectProtocol {
    
    /// 헤더 뷰의 버튼이 탭되었을 때 호출되는 선택적 메서드
    @objc optional func headerButtonDidTap(_ headerView: UICollectionReusableView)
}

/// MediumVideoCell 내에서 버튼 액션이 발생했을 때 delegate에게 이벤트를 전달하는 프로토콜
@objc protocol MediumVideoButtonDelegate: NSObjectProtocol {

    /// 셀 내부의 삭제(또는 기타) 버튼이 탭되었을 때 호출되는 선택적 메서드
    @objc optional func deleteAction(_ collectionViewCell: UICollectionViewCell)
}

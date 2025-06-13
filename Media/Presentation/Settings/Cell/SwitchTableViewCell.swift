//
//  SwitchTableViewCell.swift
//  Media
//
//  Created by 강민지 on 6/11/25.
//

import UIKit

/// 커스텀 스위치 셀 클래스
/// 아이콘, 타이틀, 서브타이틀, 토글 스위치로 구성되어 있음
/// 스위치 상태 변경 시 콜백을 통해 외부로 전달할 수 있음
class SwitchTableViewCell: UITableViewCell, NibLodable {
    /// 셀 왼쪽에 표시되는 아이콘 이미지 뷰
    @IBOutlet weak var iconImageView: UIImageView!
    
    /// 셀 중앙에 표시되는 타이틀
    @IBOutlet weak var titleLabel: UILabel!
    
    /// 셀 중앙 타이틀 아래에 표시되는 설명 텍스트
    @IBOutlet weak var subtitleLabel: UILabel!
    
    /// 셀 우측에 표시되는 토글 스위치
    @IBOutlet weak var toggleSwitch: UISwitch!
    
    /// 스위치 값 변경 시 호출되는 클로저
    /// - 매개변수 isOn: 스위치가 켜져 있는지 여부
    var onSwitchToggle: ((Bool) -> Void)?
    
    /// 스위치의 상태가 변경되었을 때 호출되는 액션 메서드
    /// 연결된 `onSwitchToggle` 클로저를 실행함
    @IBAction func switchModeChanged(_ sender: UISwitch) {
        onSwitchToggle?(sender.isOn)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}

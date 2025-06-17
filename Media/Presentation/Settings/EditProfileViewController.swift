//
//  EditProfileViewController.swift
//  Media
//
//  Created by 강민지 on 6/12/25.
//

import UIKit

/// 사용자 정보 편집 타입
/// - name: 이름 편집
/// - email: 이메일 편집
enum EditType {
    case name
    case email
}

/// 사용자 정보 편집 후 변경된 값을 전달하는 델리게이트 프로토콜
protocol EditProfileDelegate: AnyObject {
    /// 이름이 저장되었을 때 호출되는 메서드
    func didSaveName(_ name: String)
    
    /// 이메일이 저장되었을 때 호출되는 메서드
    func didSaveEmail(_ email: String)
}

/// 이름 또는 이메일을 수정할 수 있는 편집 화면
class EditProfileViewController: UIViewController, NavigationBarDelegate {
    /// 현재 편집 중인 항목 (이름 또는 이메일)
    var editType: EditType = .name
    
    /// 변경된 정보를 전달할 델리게이트
    weak var delegate: EditProfileDelegate?
    
    /// 현재 표시할 텍스트 (이름 또는 이메일)
    var currentText: String = ""
    
    /// 상단 커스텀 내비게이션 바
    @IBOutlet weak var navigationBar: NavigationBar!
    
    /// 사용자 입력을 받는 텍스트 필드
    @IBOutlet weak var textField: UITextField!
    
    /// 이름과 이메일에 따라 최대 입력 길이를 다르게 설정
    private var maxLength: Int {
        switch editType {
        case .name:
            return 15
        case .email:
            return 25
        }
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBar.delegate = self
        textField.delegate = self
        
        textField.text = currentText
        
        // 내비게이션 바 설정
        switch editType {
        case .name:
            navigationBar.configure(
                title: "Edit Name",
                leftIcon: UIImage(systemName: "xmark.circle"),
                leftIconTint: UIColor.red,
                rightIcon: UIImage(systemName: "checkmark.circle"),
                rightIconTint: UIColor.primaryColor,
                isSearchMode: false,
                isLeadingAligned: false
            )
            
            textField.placeholder = "Enter Your Name"
        case .email:
            navigationBar.configure(
                title: "Edit E-mail",
                leftIcon: UIImage(systemName: "xmark.circle"),
                leftIconTint: UIColor.red,
                rightIcon: UIImage(systemName: "checkmark.circle"),
                rightIconTint: UIColor.primaryColor,
                isSearchMode: false,
                isLeadingAligned: false
            )
            
            textField.placeholder = "Enter Your E-mail"
        }
    }
    
    // MARK: - NavigationBarDelegate
    
    /// 왼쪽 아이콘 버튼이 탭되었을 때 호출
    func navigationBarDidTapLeft(_ navigationBar: NavigationBar) {
        dismiss(animated: true)
    }
    
    /// 오른쪽 아이콘 버튼이 탭되었을 때 호출
    /// 입력된 텍스트를 델리게이트로 전달한 후 화면을 닫음
    func navigationBarDidTapRight(_ navigationBar: NavigationBar) {
        let text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        switch editType {
        case .name:
            delegate?.didSaveName(text)
        case .email:
            delegate?.didSaveEmail(text)
        }
        
        dismiss(animated: true)
    }
}

extension EditProfileViewController: UITextFieldDelegate {
    // 리턴 키를 눌렀을 때 키보드가 내려가게 함
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        
        // 입력 범위를 Swift 문자열 Range로 변환
        guard let stringRange = Range(range, in: currentText) else { return false }
        // 입력될 텍스트 반영 후 전체 문자열 계산
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)

        // 최대 글자 수 초과 시 진동 피드백 후 입력 차단
        if updatedText.count > maxLength {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.warning)
            return false
        }

        return true
    }
}

//
//  EditProfileViewController.swift
//  Media
//
//  Created by 강민지 on 6/12/25.
//

import UIKit

enum EditType {
    case name
    case email
}

protocol EditProfileDelegate: AnyObject {
    func didSaveName(_ name: String)
    func didSaveEmail(_ email: String)
}

class EditProfileViewController: UIViewController, NavigationBarDelegate {
    var editType: EditType = .name
    weak var delegate: EditProfileDelegate?
    var currentText: String = ""
    
    @IBOutlet weak var navigationBar: NavigationBar!
    @IBOutlet weak var textField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBar.delegate = self
        
        textField.text = currentText
        
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
        }
    }
    
    func navigationBarDidTapLeft(_ navigationBar: NavigationBar) {
        print("왼쪽 버튼 탭됨")
        dismiss(animated: true)
    }

    func navigationBarDidTapRight(_ navigationBar: NavigationBar) {
        let text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        switch editType {
        case .name:
            delegate?.didSaveName(text)
        case .email:
            delegate?.didSaveEmail(text)
        }
                
        print("오른쪽 버튼 탭됨")
        dismiss(animated: true)
    }
}

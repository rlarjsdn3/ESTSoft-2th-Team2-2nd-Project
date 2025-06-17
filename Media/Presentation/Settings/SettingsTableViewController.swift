//
//  SettingsTableViewController.swift
//  Media
//
//  Created by 강민지 on 6/11/25.
//

import UIKit
import MessageUI

/// 앱의 설정 화면을 관리하는 테이블 뷰 컨트롤러
/// 사용자 프로필 정보 / 비디오 해상도 설정 / 다크 모드 전환 / 피드백 이메일 전송 등의 기능을 포함함
class SettingsTableViewController: UITableViewController, EditProfileDelegate, MFMailComposeViewControllerDelegate, Alertable {
    /// 설정 화면의 섹션을 구분하는 열거형
    enum Section: Int, CaseIterable {
        case profile, videoQuality, modeFeedback
    }
    
    /// 프로필 섹션의 셀을 구분하는 열거형
    enum ProfileRow: Int, CaseIterable {
        case name, email, interests
    }
    
    /// 비디오 해상도 섹션의 셀을 구분하는 열거형
    enum VideoQualityRow: Int, CaseIterable {
        case resolution
    }
    
    /// 라이트 및 다크 모드 / 피드백 섹션의 셀을 구분하는 열거형
    enum ModeFeedbackRow: Int, CaseIterable {
        case mode, feedback
    }
        
    /// 다크 모드 활성화 여부
    var isDarkMode: Bool {
        get { userDefaults.isDarkMode }
        set { userDefaults.isDarkMode = newValue }
    }
    
    /// 사용자 기본 설정을 관리하는 서비스
    let userDefaults = UserDefaultsService.shared
    
    // MARK: - IBOutlet
    
    /// 사용자 이름 레이블
    @IBOutlet weak var nameLabel: UILabel!
    
    /// 사용자 이메일 레이블
    @IBOutlet weak var emailLabel: UILabel!
    
    /// 현재 비디오 해상도 레이블
    @IBOutlet weak var videoQualityLabel: UILabel!
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 사용자 정보 및 해상도 표시
        nameLabel.text = userDefaults.userName
        emailLabel.text = userDefaults.userEmail
        videoQualityLabel.text = currentVideoQuality.rawValue

        // 커스텀 스위치 셀 등록
        tableView.register(SwitchTableViewCell.nib, forCellReuseIdentifier: SwitchTableViewCell.id)
        
        // interests 셀 클릭 시 뜨는 모달을 닫기 위한 작업
        // 'didSelectedCategories'이라는 Notification이 발생하면
        // 'didReceiveSelectedCategories' 메서드를 호출
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didReceiveSelectedCategories),
            name: .didSelectedCategories,
            object: nil
        )
    }
    
    /// 프로필 수정 화면으로 이동 전 사용자 정보 전달
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EditNameSegue",
           let editVC = segue.destination as? EditProfileViewController {
            editVC.editType = .name
            editVC.delegate = self
            editVC.currentText = userDefaults.userName ?? ""
        }
        
        if segue.identifier == "EditEmailSegue",
           let editVC = segue.destination as? EditProfileViewController {
            editVC.editType = .email
            editVC.delegate = self
            editVC.currentText = userDefaults.userEmail ?? ""
        }
    }
    
    // MARK: - Notification
    
    @objc private func didReceiveSelectedCategories(_ notification: Notification) {
        // 띄운 모달이 있으면 닫기
        if let presented = self.presentedViewController {
            presented.dismiss(animated: true)
        }
    }
    
    // MARK: - EditProfileDelegate
    
    /// 이름 저장 후 UI와 저장소 갱신
    func didSaveName(_ name: String) {
        nameLabel.text = name
        userDefaults.userName = name
        tableView.reloadData()
    }
    
    /// 이메일 저장 후 UI와 저장소 갱신
    func didSaveEmail(_ email: String) {
        emailLabel.text = email
        userDefaults.userEmail = email
        tableView.reloadData()
    }
    
    // MARK: - MFMailComposeViewControllerDelegate
    
    /// 메일 작성 종료 시 호출
    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult,
                               error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Table View Data Source
    
    /// 섹션 개수 반환
    override func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allCases.count
    }
    
    /// 섹션별 셀 개수 반환
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = Section(rawValue: section) else { return 0 }
        
        switch section {
        case .profile: return ProfileRow.allCases.count
        case .videoQuality: return VideoQualityRow.allCases.count
        case .modeFeedback: return ModeFeedbackRow.allCases.count
        }
    }
        
    /// 셀 구성
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = Section(rawValue: indexPath.section) else {
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
        
        // 라이트 및 다크 모드 스위치 셀 구성
        if section == .modeFeedback, indexPath.row == ModeFeedbackRow.mode.rawValue {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SwitchTableViewCell.id, for: indexPath) as? SwitchTableViewCell else {
                return UITableViewCell()
            }
            
            cell.titleLabel.text = isDarkMode ? "Dark Mode" : "Light Mode"
            cell.subtitleLabel.text = isDarkMode ? "Switch to Light Mode" : "Switch to Dark Mode"
            cell.iconImageView.image = UIImage(systemName: isDarkMode ? "moon.stars" : "sun.max")
            cell.toggleSwitch.isOn = isDarkMode
            
            cell.onSwitchToggle = { [weak self] isOn in
                guard let self = self else { return }
                self.isDarkMode = isOn
                
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let window = windowScene.windows.first {
                    window.overrideUserInterfaceStyle = self.isDarkMode ? .dark : .light
                }
                
                tableView.reloadData()
            }
            
            return cell
        }
        
        // 나머지 셀은 storyboard에 정의된 셀 사용
        return super.tableView(tableView, cellForRowAt: indexPath)
    }

    // MARK: - Table View Delegate
    
    /// 헤더 뷰 디자인 설정
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header = view as? UITableViewHeaderFooterView {
            header.textLabel?.font = UIFont.systemFont(ofSize: 17, weight: .medium)
            header.textLabel?.textColor = UIColor.primaryColor
            header.contentView.backgroundColor = UIColor.backgroundColor
        }
    }

    /// 섹션 간 여백
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 45
    }
    
    /// 셀의 높이
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }


    /// 셀 선택 시 동작 정의
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let section = Section(rawValue: indexPath.section) else { return }
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        // 프로필 섹션 선택 시
        if section == .profile {
            switch ProfileRow(rawValue: indexPath.row) {
            case .name:
                performSegue(withIdentifier: "EditNameSegue", sender: nil)
            case .email:
                performSegue(withIdentifier: "EditEmailSegue", sender: nil)
            case .interests:
                let storyboard = UIStoryboard(name: "SelectedTagsViewController", bundle: nil)
                if let interestVC = storyboard.instantiateViewController(withIdentifier: "SelectedTagsViewController") as? SelectedTagsViewController {
                    let nav = UINavigationController(rootViewController: interestVC)
                    nav.modalPresentationStyle = .automatic
                    present(nav, animated: true)
                }
                break
            case .none:
                break
            }
        }
        
        // 비디오 해상도 섹션 선택 시
        if section == .videoQuality {
            let alert = UIAlertController(title: "Select Video Quality", message: nil, preferredStyle: .actionSheet)
            
            for quality in VideoQuality.allCases {
                let action = UIAlertAction(title: quality.rawValue, style: .default) { [weak self] _ in
                    guard let self = self else { return }
                    
                    // 선택한 해상도를 UserDefaults에 저장
                    self.currentVideoQuality = quality
                    
                    // UI 업데이트
                    self.videoQualityLabel.text = quality.rawValue

                    tableView.reloadData()
                }
                alert.addAction(action)
            }
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            
            // iPad 대응
            if let popover = alert.popoverPresentationController {
                if let cell = tableView.cellForRow(at: indexPath) {
                    popover.sourceView = cell
                    popover.sourceRect = cell.bounds
                } else {
                    popover.sourceView = self.view
                    popover.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
                }
                popover.permittedArrowDirections = [.up, .down]
            }
            
            present(alert, animated: true)
        }
        
        // 피드백 메일 전송
        if section == .modeFeedback {
            switch ModeFeedbackRow(rawValue: indexPath.row) {
            case .feedback:
                if MFMailComposeViewController.canSendMail() {
                    let mailComposeVC = MFMailComposeViewController()
                    mailComposeVC.mailComposeDelegate = self
                    mailComposeVC.setToRecipients(["aldalddl2007@gmail.com"]) // TODO: 팀 이메일로 설정
                    mailComposeVC.setSubject("App Feedback") // 메일 제목
                    
                    // 유저 정보 가져오기
                    let name = userDefaults.userName ?? "Unknown"
                    let email = userDefaults.userEmail ?? "Unknown"
                    
                    // 메일 본문 구성
                    let messageBody = """
                    [User Name] \(name)
                    [User Email] \(email)
                    
                    ---------------------------
                    Please write your feedback below:
                    """

                    mailComposeVC.setMessageBody(messageBody, isHTML: false)

                    present(mailComposeVC, animated: true, completion: nil)
                } else {
                    showAlert(
                        title: "Mail App Not Set Up",
                        message: "Please check your device's mail settings.",
                        onPrimary: { _ in }
                    )
                }
            default:
                break
            }
        }
    }
}

extension SettingsTableViewController {
    /// UserDefaultsService에 저장된 비디오 해상도 문자열 값을
    /// VideoQuality enum으로 변환하여 반환. 유효하지 않으면 기본값(.medium)을 반환
    /// 저장 시에도 enum의 rawValue(String)를 UserDefaults에 저장
    var currentVideoQuality: VideoQuality {
        get {
            let saved = userDefaults.videoQuality
            return VideoQuality(rawValue: saved) ?? .medium
        }
        set {
            userDefaults.videoQuality = newValue.rawValue
        }
    }
}

//
//  SettingsTableViewController.swift
//  Media
//
//  Created by 강민지 on 6/11/25.
//

import UIKit
import MessageUI

class SettingsTableViewController: UITableViewController, EditProfileDelegate, MFMailComposeViewControllerDelegate {
    enum Section: Int, CaseIterable {
        case profile, videoQuality, modeFeedback
    }
    
    enum ProfileRow: Int, CaseIterable {
        case name, email, interests
    }
    
    enum VideoQualityRow: Int, CaseIterable {
        case resolution
    }
    
    enum ModeFeedbackRow: Int, CaseIterable {
        case mode, feedback
    }
    
    var currentResolution = "1080 x 1024"
    var isDarkMode = false
    
    let userDefaults = UserDefaultsService.shared
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 이름 / 이메일 표시
        nameLabel.text = userDefaults.userName
        emailLabel.text = userDefaults.userEmail
        
        // 다크 모드 설정값 불러오기
        isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
        
        tableView.register(SwitchTableViewCell.nib, forCellReuseIdentifier: SwitchTableViewCell.id)
    }
    
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
    
    func didSaveName(_ name: String) {
        nameLabel.text = name
        userDefaults.userName = name
        tableView.reloadData()
    }
    
    func didSaveEmail(_ email: String) {
        emailLabel.text = email
        userDefaults.userEmail = email
        tableView.reloadData()
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult,
                               error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Table View Data Source & Delegate
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allCases.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = Section(rawValue: section) else { return 0 }
        
        switch section {
        case .profile: return ProfileRow.allCases.count
        case .videoQuality: return VideoQualityRow.allCases.count
        case .modeFeedback: return ModeFeedbackRow.allCases.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = Section(rawValue: indexPath.section) else {
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
        
        
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
                UserDefaults.standard.set(isOn, forKey: "isDarkMode")
                
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let window = windowScene.windows.first {
                    window.overrideUserInterfaceStyle = self.isDarkMode ? .dark : .light
                }
                
                tableView.reloadRows(at: [indexPath], with: .none)
            }
            
            return cell
        }
        
        // 정적 셀인 경우는 스토리보드 기반 셀을 반환하도록
        return super.tableView(tableView, cellForRowAt: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let section = Section(rawValue: indexPath.section) else { return }
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if section == .profile {
            switch ProfileRow(rawValue: indexPath.row) {
            case .name:
                performSegue(withIdentifier: "EditNameSegue", sender: nil)
            case .email:
                performSegue(withIdentifier: "EditEmailSegue", sender: nil)
            case .interests:
                let storyboard = UIStoryboard(name: "SelectedTagsViewController", bundle: nil)
                if let interestVC = storyboard.instantiateViewController(withIdentifier: "SelectedTagsViewController") as? SelectedTagsViewController {
                    interestVC.modalPresentationStyle = .automatic
                    present(interestVC, animated: true)
                }
                break
            case .none:
                break
            }
        }
        
        if section == .modeFeedback {
            switch ModeFeedbackRow(rawValue: indexPath.row) {
            case .feedback:
                if MFMailComposeViewController.canSendMail() {
                    let mailComposeVC = MFMailComposeViewController()
                    mailComposeVC.mailComposeDelegate = self
                    mailComposeVC.setToRecipients(["ddd@example.com"]) // 수신자 이메일
                    mailComposeVC.setSubject("App Feedback") // 메일 제목
                    mailComposeVC.setMessageBody("feedback", isHTML: false) // 메일 내용
                    present(mailComposeVC, animated: true, completion: nil)
                } else {
                    let alert = UIAlertController(title: "메일 앱이 설정되지 않았습니다", message: "기기의 메일 설정을 확인해 주세요.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "확인", style: .default))
                    present(alert, animated: true)
                }
            default:
                break
            }
        }
    }
}

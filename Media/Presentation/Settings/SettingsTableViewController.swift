//
//  SettingsTableViewController.swift
//  Media
//
//  Created by 강민지 on 6/11/25.
//

import UIKit

class SettingsTableViewController: UITableViewController {
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
    
    var userName = "Kim"
    var userEmail = "Kim123@gmail.com"
    var currentResolution = "1080 x 1024"
    var isDarkMode = false
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 이름 / 이메일 표시
        nameLabel.text = userName
        emailLabel.text = userEmail
        
        // 다크 모드 설정값 불러오기
        isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
        
        tableView.register(SwitchTableViewCell.nib, forCellReuseIdentifier: SwitchTableViewCell.id)
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
        
        if section == .profile, ProfileRow(rawValue: indexPath.row) == .interests {
            // TODO: InterestsViewController 띄우기 (modal or sheet)
        }
    }
}

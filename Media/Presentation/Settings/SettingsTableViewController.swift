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
}

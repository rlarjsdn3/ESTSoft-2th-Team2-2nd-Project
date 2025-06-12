//
//  SettingsViewController.swift
//  Media
//
//  Created by 김건우 on 6/5/25.
//

import UIKit

final class SettingsViewController: StoryboardViewController {
    @IBOutlet weak var navigationBar: NavigationBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBar.configure(
            title: "Settings",
            subtitle: "",
            isSearchMode: false,
            isLeadingAligned: false
        )
    }

    override func setupAttributes() {
        super.setupAttributes()
    }
}

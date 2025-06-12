//
//  SwitchTableViewCell.swift
//  Media
//
//  Created by 강민지 on 6/11/25.
//

import UIKit

class SwitchTableViewCell: UITableViewCell, NibLodable {
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var toggleSwitch: UISwitch!
    
    var onSwitchToggle: ((Bool) -> Void)?

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

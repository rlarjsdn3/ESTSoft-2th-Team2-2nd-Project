//
//  SearchTableViewCell.swift
//  Media
//
//  Created by 백현진 on 6/9/25.
//

import UIKit

class SearchTableViewCell: UITableViewCell {
    @IBOutlet weak var searchLabel: UILabel!

    private var returnBackgroundColor: UIColor?

    override func awakeFromNib() {
        super.awakeFromNib()

        selectionStyle = .none
    	returnBackgroundColor = contentView.backgroundColor
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)

        contentView.backgroundColor = highlighted
        ? UIColor.systemGray4
        : returnBackgroundColor
    }
}

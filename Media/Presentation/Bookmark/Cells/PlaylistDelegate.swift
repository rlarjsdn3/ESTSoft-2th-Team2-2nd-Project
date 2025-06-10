//
//  PlaylistDelegate.swift
//  Media
//
//  Created by Heejung Yang on 6/10/25.
//

import UIKit

@objc protocol HeaderButtonDelegate: NSObjectProtocol {
    @objc optional func HeaderButtonDidTap(_ headerView: UICollectionReusableView)
}

//
//  PlaylistDelegate.swift
//  Media
//
//  Created by Heejung Yang on 6/10/25.
//

import UIKit

@objc protocol HeaderButtonDelegate: NSObjectProtocol {
    @objc optional func headerButtonDidTap(_ headerView: UICollectionReusableView)
}

@objc protocol MediumVideoButtonDelegate: NSObjectProtocol {
    @objc optional func deleteAction(_ collectionViewCell: UICollectionViewCell)
}

//
//  NavigationBarDelegate.swift
//  Media
//
//  Created by 강민지 on 6/8/25.
//

import Foundation

protocol NavigationBarDelegate: AnyObject {
    func navigationBarDidTapLeft(_ navBar: NavigationBar)
    func navigationBarDidTapRight(_ navBar: NavigationBar)
}

//
//  Order.swift
//  Media
//
//  Created by 김건우 on 6/8/25.
//

import Foundation

enum Order: String, CaseIterable {
    case latest
    case popular

    var displayName: String {
        return rawValue.prefix(1).uppercased()
        + rawValue.dropFirst()
    }
}

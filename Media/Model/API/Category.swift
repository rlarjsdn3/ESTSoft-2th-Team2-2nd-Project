//
//  Category.swift
//  Media
//
//  Created by 김건우 on 6/8/25.
//

import Foundation
import UIKit

enum Category: String, CaseIterable {
    case backgrounds
    case fashion
    case nature
    case science
    case education
    case feelings
    case health
    case people
    case religion
    case places
    case animals
    case industry
    case computer
    case food
    case sports
    case transportation
    case travel
    case buildings
    case business
    case music

    var displayName: String {
        return rawValue.prefix(1).uppercased()
        + rawValue.dropFirst()
    }

    var symbolImage: UIImage? {
        switch self {
        case .backgrounds:
            return UIImage(systemName: "photo")
        case .fashion:
            return UIImage(systemName: "tshirt.fill")
        case .nature:
            return UIImage(systemName: "leaf.fill")
        case .science:
            return UIImage(systemName: "atom")
        case .education:
            return UIImage(systemName: "book.fill")
        case .feelings:
            return UIImage(systemName: "face.smiling.inverse")
        case .health:
            return UIImage(systemName: "heart.fill")
        case .people:
            return UIImage(systemName: "person.3.fill")
        case .religion:
            return UIImage(systemName: "hands.and.sparkles.fill")
        case .places:
            return UIImage(systemName: "map.fill")
        case .animals:
            return UIImage(systemName: "pawprint.fill")
        case .industry:
            return UIImage(systemName: "wrench.and.screwdriver.fill")
        case .computer:
            return UIImage(systemName: "desktopcomputer")
        case .food:
            return UIImage(systemName: "fork.knife")
        case .sports:
            return UIImage(systemName: "figure.run")
        case .transportation:
            return UIImage(systemName: "car.fill")
        case .travel:
            return UIImage(systemName: "airplane.departure")
        case .buildings:
            return UIImage(systemName: "building.2.fill")
        case .business:
            return UIImage(systemName: "briefcase.fill")
        case .music:
            return UIImage(systemName: "music.note")
        }
    }
}

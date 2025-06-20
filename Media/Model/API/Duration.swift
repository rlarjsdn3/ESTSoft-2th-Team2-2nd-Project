//
//  Duration.swift
//  Media
//
//  Created by 백현진 on 6/10/25.
//

import Foundation

/// 영상 길이(초)를 구간별로 분류하는 필터
enum Duration: CaseIterable {
    case short
    case shortMedium
    case medium
    case long

    /// 초 단위로 주어진 duration을 해당 카테고리로 매핑
    init(seconds: Int) {
        switch seconds {
        case 0...9:
            self = .short
        case 10...30:
            self = .shortMedium
        case 31...60:
            self = .medium
        case 61...:
            self = .long
        default:
            self = .short
        }
    }

    var description: String {
        switch self {
        case .short:
            return "Within 10 seconds"
        case .shortMedium:
            return "Within 30 seconds"
        case .medium:
            return "Within 1 minute"
        case .long:
            return "Over 1 minute"
        }
    }
}

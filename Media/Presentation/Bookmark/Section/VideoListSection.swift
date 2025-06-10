//
//  PlaylistSection.swift
//  Media
//
//  Created by 김건우 on 6/9/25.
//

import Foundation

enum VideoList {

    /// <#Description#>
    enum SectionType: Int, CaseIterable {
        ///
        case playlist
        ///
        case history
    }

    struct Section: Hashable {
        ///
        let type: SectionType
        ///
        let name: String?
        
        /// <#Description#>
        /// - Parameters:
        ///   - type: <#type description#>
        ///   - name: <#name description#>
        init(type: SectionType, name: String? = nil) {
            self.type = type
            self.name = name
        }
    }

    enum Item: Hashable {
        ///
        case playlist(PlaylistVideoEntity)
        ///
        case history(PlaybackHistoryEntity)

        func hash(into hasher: inout Hasher) {
            switch self {
            case .playlist(let entity):
                hasher.combine(entity.id)
            case .history(let entity):
                hasher.combine(entity.id)
            }
        }
    }
}

//
//  PlaylistSection.swift
//  Media
//
//  Created by 김건우 on 6/9/25.
//

import Foundation

enum Playlist {

    /// <#Description#>
    enum Section: Int, CaseIterable {
        ///
        case playlist
    }

    enum Item: Hashable {
        ///
        case playlist(PlaylistVideoEntity)

        func hash(into hasher: inout Hasher) {
            switch self {
            case .playlist(let entity):
                hasher.combine(entity.id)
            }
        }
    }
}

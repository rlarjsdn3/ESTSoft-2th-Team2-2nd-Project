//
//  PlaylistVideoEntity+Mapping.swift
//  Media
//
//  Created by 김건우 on 6/9/25.
//

import Foundation
import CoreData

extension PlaylistVideoEntity {
    
    /// <#Description#>
    /// - Returns: <#description#>
    func mapToPixabayHit() -> PixabayResponse.Hit? {
        guard let video = self.video else { return nil }
        
        return PixabayResponse.Hit(
            id: Int(self.id),
            pageUrl: self.pageUrl,
            type: .film,  // placeholder
            tags: self.tags,
            duration: Int(self.duration),
            videos: video.mapToPixabayVideoVariants(),
            views: Int(self.views),
            downloads: 0, // placeholder
            likes: Int(self.likes),
            comments: 0,  // placeholder
            userId: Int(self.userId),
            user: self.user,
            userImageUrl: self.userImageUrl
        )
    }
}

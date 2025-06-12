//
//  PlaylistEntity+Convenience.swift
//  Media
//
//  Created by 김건우 on 6/11/25.
//

import Foundation
import CoreData

extension PlaylistEntity {
    
    /// <#Description#>
    /// - Parameters:
    ///   - name: <#name description#>
    ///   - context: <#context description#>
    convenience init(
        name: String,
        isBookmark: Bool = false,
        insertInto context: NSManagedObjectContext
    ) {
        self.init(context: context)
        self.name = name
        self.isBookmark = isBookmark
        self.createdAt = Date()
    }
}

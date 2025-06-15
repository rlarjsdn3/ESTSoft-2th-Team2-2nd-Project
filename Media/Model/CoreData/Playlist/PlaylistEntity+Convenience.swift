//
//  PlaylistEntity+Convenience.swift
//  Media
//
//  Created by 김건우 on 6/11/25.
//

import Foundation
import CoreData

extension PlaylistEntity {
    
    /// 이름과 북마크 여부를 지정하여 새로운 엔터티를 생성합니다.
    /// - Parameters:
    ///   - name: 생성할 엔터티의 이름입니다.
    ///   - isBookmark: 북마크 여부를 나타내는 플래그입니다. 기본값은 `false`입니다.
    ///   - context: 엔터티를 삽입할 `NSManagedObjectContext`입니다.
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

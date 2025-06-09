//
//  PlaybackHistoryEntity+CoreDataProperties.swift
//  Media
//
//  Created by 김건우 on 6/9/25.
//
//

import Foundation
import CoreData


extension PlaybackHistoryEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PlaybackHistoryEntity> {
        return NSFetchRequest<PlaybackHistoryEntity>(entityName: "PlaybackHistoryEntity")
    }

    @NSManaged public var id: Int64
    @NSManaged public var pageUrl: URL
    @NSManaged public var views: Int64
    @NSManaged public var userId: Int64
    @NSManaged public var user: String
    @NSManaged public var userImageUrl: URL
    @NSManaged public var video: VideoVariantsEntity

}

extension PlaybackHistoryEntity : Identifiable {

}

//
//  PlaylistVideoEntity+CoreDataProperties.swift
//  Media
//
//  Created by 김건우 on 6/10/25.
//
//

import Foundation
import CoreData


extension PlaylistVideoEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PlaylistVideoEntity> {
        return NSFetchRequest<PlaylistVideoEntity>(entityName: "PlaylistVideoEntity")
    }

    @NSManaged public var id: Int64
    @NSManaged public var pageUrl: URL
    @NSManaged public var user: String
    @NSManaged public var userId: Int64
    @NSManaged public var userImageUrl: URL
    @NSManaged public var views: Int64
    @NSManaged public var tags: String
    @NSManaged public var likes: Int64
    @NSManaged public var duration: Int64
    @NSManaged public var playlist: PlaylistEntity?
    @NSManaged public var video: VideoVariantsEntity?

}

extension PlaylistVideoEntity : Identifiable {

}

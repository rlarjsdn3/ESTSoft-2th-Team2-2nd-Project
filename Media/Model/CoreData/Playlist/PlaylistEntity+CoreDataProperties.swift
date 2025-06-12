//
//  PlaylistEntity+CoreDataProperties.swift
//  Media
//
//  Created by 김건우 on 6/9/25.
//
//

import Foundation
import CoreData


extension PlaylistEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PlaylistEntity> {
        return NSFetchRequest<PlaylistEntity>(entityName: "PlaylistEntity")
    }

    @NSManaged public var createdAt: Date
    @NSManaged public var name: String
    @NSManaged public var playlistVideos: NSSet?

}

// MARK: Generated accessors for playlistVideos
extension PlaylistEntity {

    @objc(addPlaylistVideosObject:)
    @NSManaged public func addToPlaylistVideos(_ value: PlaylistVideoEntity)

    @objc(removePlaylistVideosObject:)
    @NSManaged public func removeFromPlaylistVideos(_ value: PlaylistVideoEntity)

    @objc(addPlaylistVideos:)
    @NSManaged public func addToPlaylistVideos(_ values: NSSet)

    @objc(removePlaylistVideos:)
    @NSManaged public func removeFromPlaylistVideos(_ values: NSSet)

}

extension PlaylistEntity : Identifiable {

}

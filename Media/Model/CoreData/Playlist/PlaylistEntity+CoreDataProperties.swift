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

    @NSManaged public var name: String?
    @NSManaged public var createdAt: Date?
    @NSManaged public var playlistVideos: NSOrderedSet?

}

// MARK: Generated accessors for playlistVideos
extension PlaylistEntity {

    @objc(insertObject:inPlaylistVideosAtIndex:)
    @NSManaged public func insertIntoPlaylistVideos(_ value: PlaylistVideoEntity, at idx: Int)

    @objc(removeObjectFromPlaylistVideosAtIndex:)
    @NSManaged public func removeFromPlaylistVideos(at idx: Int)

    @objc(insertPlaylistVideos:atIndexes:)
    @NSManaged public func insertIntoPlaylistVideos(_ values: [PlaylistVideoEntity], at indexes: NSIndexSet)

    @objc(removePlaylistVideosAtIndexes:)
    @NSManaged public func removeFromPlaylistVideos(at indexes: NSIndexSet)

    @objc(replaceObjectInPlaylistVideosAtIndex:withObject:)
    @NSManaged public func replacePlaylistVideos(at idx: Int, with value: PlaylistVideoEntity)

    @objc(replacePlaylistVideosAtIndexes:withPlaylistVideos:)
    @NSManaged public func replacePlaylistVideos(at indexes: NSIndexSet, with values: [PlaylistVideoEntity])

    @objc(addPlaylistVideosObject:)
    @NSManaged public func addToPlaylistVideos(_ value: PlaylistVideoEntity)

    @objc(removePlaylistVideosObject:)
    @NSManaged public func removeFromPlaylistVideos(_ value: PlaylistVideoEntity)

    @objc(addPlaylistVideos:)
    @NSManaged public func addToPlaylistVideos(_ values: NSOrderedSet)

    @objc(removePlaylistVideos:)
    @NSManaged public func removeFromPlaylistVideos(_ values: NSOrderedSet)

}

extension PlaylistEntity : Identifiable {

}

//
//  VideoDataService.swift
//  Media
//
//  Created by 백현진 on 6/13/25.
//

import CoreData
import Foundation

final class VideoDataService {
    static let shared = VideoDataService()
    private let context: NSManagedObjectContext

    private init(
        context: NSManagedObjectContext = CoreDataService.shared.viewContext
    ) {
        self.context = context
    }

    // MARK: – Playback History

    func addToWatchHistory(_ video: PixabayResponse.Hit) {
        let req: NSFetchRequest<PlaybackHistoryEntity> = PlaybackHistoryEntity.fetchRequest()
        req.predicate = NSPredicate(format: "id == %d", video.id)
        if let existing = try? context.fetch(req) {
            existing.forEach(context.delete)
        }

        let history = video.mapToPlaybackHistoryEntity(insertInto: context)
        history.createdAt = Date()
        try? context.save()
    }

    // MARK: – Bookmarks

    private func fetchOrCreateBookmarkPlaylist() -> PlaylistEntity {
        let req: NSFetchRequest<PlaylistEntity> = PlaylistEntity.fetchRequest()
        req.predicate = NSPredicate(format: "isBookmark == true")
        if let pl = (try? context.fetch(req))?.first {
            return pl
        }
        let newPl = PlaylistEntity(context: context)
        newPl.name = CoreDataService.StaticString.bookmarkedPlaylistName
        newPl.createdAt = Date()
        newPl.isBookmark = true
        try? context.save()
        return newPl
    }

    @discardableResult
    func addToBookmark(_ video: PixabayResponse.Hit) -> Result<Void, Error> {
        let bookmarkPL = fetchOrCreateBookmarkPlaylist()
        let req: NSFetchRequest<PlaylistVideoEntity> = PlaylistVideoEntity.fetchRequest()
        req.predicate = NSPredicate(
            format: "id == %d AND playlist == %@", video.id, bookmarkPL
        )

        if let existing = try? context.fetch(req), !existing.isEmpty {
            return .failure(NSError(
                domain: "VideoDataService",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "이미 북마크에 있습니다"]
            ))
        }

        let pe = video.mapToPlaylistVideoEntity(insertInto: context)
        bookmarkPL.addToPlaylistVideos(pe)
        try? context.save()
        return .success(())
    }

    // MARK: – Custom Playlists

    func playlists() -> [PlaylistEntity] {
        let req: NSFetchRequest<PlaylistEntity> = PlaylistEntity.fetchRequest()
        req.predicate = NSPredicate(format: "isBookmark == false")
        return (try? context.fetch(req)) ?? []
    }

    @discardableResult
    func add(_ video: PixabayResponse.Hit, toPlaylistNamed name: String) -> Result<Void, Error> {
        let req: NSFetchRequest<PlaylistEntity> = PlaylistEntity.fetchRequest()
        req.predicate = NSPredicate(format: "name == %@", name)
        guard let pl = (try? context.fetch(req))?.first else {
            return .failure(NSError(
                domain: "VideoDataService",
                code: 2,
                userInfo: [NSLocalizedDescriptionKey: "플레이리스트를 찾을 수 없습니다"]
            ))
        }
        let pe = video.mapToPlaylistVideoEntity(insertInto: context)
        pl.addToPlaylistVideos(pe)
        try? context.save()
        return .success(())
    }

    @discardableResult
    func createPlaylist(named name: String, with video: PixabayResponse.Hit) -> Result<Void, Error> {
        guard !PlaylistEntity.isExist(name) else {
            return .failure(NSError(
                domain: "VideoDataService",
                code: 3,
                userInfo: [NSLocalizedDescriptionKey: "이미 존재하는 재생 목록 이름입니다"]
            ))
        }
        let pl = PlaylistEntity(context: context)
        pl.name = name
        pl.createdAt = Date()
        pl.isBookmark = false

        let pe = video.mapToPlaylistVideoEntity(insertInto: context)
        pl.addToPlaylistVideos(pe)
        try? context.save()
        return .success(())
    }
}

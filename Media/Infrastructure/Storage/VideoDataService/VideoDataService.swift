//
//  VideoDataService.swift
//  Media
//
//  Created by 백현진 on 6/13/25.
//

import CoreData
import Foundation

/// 비디오 시청 기록, 북마크, 커스텀 재생목록 관리를 담당하는 서비스 클래스입니다.
/// CoreDataService의 Context를 활용하여 PlaybackHistoryEntity, PlaylistEntity, PlaylistVideoEntity를 CRUD 합니다.
final class VideoDataService {

    /// 전역에서 사용할 수 있는 싱글톤
    static let shared = VideoDataService()
    private let context: NSManagedObjectContext

    /// 초기화 (외부에서 직접 Context를 주입할 수도 있습니다)
    private init(
        context: NSManagedObjectContext = CoreDataService.shared.viewContext
    ) {
        self.context = context
    }

    // MARK: – Playback History

    /// 지정한 비디오를 시청 기록에 추가합니다.
    /// - Parameter video: 추가할 PixabayResponse.Hit 모델
    /// - Note: 중복된 기록이 있으면 먼저 삭제한 뒤, 새로 삽입합니다.
    func addToWatchHistory(_ video: PixabayResponse.Hit) {
        let request: NSFetchRequest<PlaybackHistoryEntity> = PlaybackHistoryEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", video.id)

        // 기존 기록 삭제
        if let existing = try? context.fetch(request) {
            existing.forEach(context.delete)
        }

        // 새 기록 생성 및 저장
        let history = video.mapToPlaybackHistoryEntity(insertInto: context)
        history.createdAt = Date()
        try? context.save()
    }

    // MARK: – Bookmarks

    /// “북마크” 전용 플레이리스트를 가져오거나, 없으면 새로 생성합니다.
    /// - Returns: 북마크 전용 PlaylistEntity
    private func fetchOrCreateBookmarkPlaylist() -> PlaylistEntity {
        let request: NSFetchRequest<PlaylistEntity> = PlaylistEntity.fetchRequest()
        request.predicate = NSPredicate(format: "isBookmark == true")

        if let existing = (try? context.fetch(request))?.first {
            return existing
        }

        let newPlaylist = PlaylistEntity(context: context)
        newPlaylist.name       = CoreDataService.StaticString.bookmarkedPlaylistName
        newPlaylist.createdAt  = Date()
        newPlaylist.isBookmark = true
        try? context.save()
        return newPlaylist
    }

    /// 지정한 비디오를 북마크에 추가합니다.
    /// - Parameter video: 북마크에 추가할 PixabayResponse.Hit 모델
    /// - Returns: 성공 시 `.success(())`, 이미 존재하면 `.failure(Error)` 반환
    @discardableResult
    func addToBookmark(_ video: PixabayResponse.Hit) -> Result<Void, Error> {
        let bookmarkPlaylist = fetchOrCreateBookmarkPlaylist()
        let request: NSFetchRequest<PlaylistVideoEntity> = PlaylistVideoEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d AND playlist == %@", video.id, bookmarkPlaylist)

        // 중복 검사
        if let existing = try? context.fetch(request), !existing.isEmpty {
            return .failure(NSError(
                domain: "VideoDataService",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "이미 북마크에 있습니다"]
            ))
        }

        // 새 PlaylistVideoEntity 생성 및 저장
        let pe = video.mapToPlaylistVideoEntity(insertInto: context)
        bookmarkPlaylist.addToPlaylistVideos(pe)
        try? context.save()
        return .success(())
    }

    // MARK: – Custom Playlists

    /// “북마크”가 아닌 커스텀 재생목록 목록을 조회합니다.
    /// - Returns: 사용자 정의 PlaylistEntity 배열
    func playlists() -> [PlaylistEntity] {
        let request: NSFetchRequest<PlaylistEntity> = PlaylistEntity.fetchRequest()
        request.predicate = NSPredicate(format: "isBookmark == false")
        return (try? context.fetch(request)) ?? []
    }

    /// 지정한 이름의 재생목록에 비디오를 추가합니다.
    /// - Parameters:
    ///   - video: 추가할 PixabayResponse.Hit 모델
    ///   - name: 대상 재생목록 이름
    /// - Returns: 성공 시 `.success(())`, 없는 이름이면 `.failure(Error)` 반환
    @discardableResult
    func add(_ video: PixabayResponse.Hit, toPlaylistNamed name: String) -> Result<Void, Error> {
        let request: NSFetchRequest<PlaylistEntity> = PlaylistEntity.fetchRequest()
        request.predicate = NSPredicate(format: "name == %@", name)

        guard let playlist = (try? context.fetch(request))?.first else {
            return .failure(NSError(
                domain: "VideoDataService",
                code: 2,
                userInfo: [NSLocalizedDescriptionKey: "플레이리스트를 찾을 수 없습니다"]
            ))
        }

        let pe = video.mapToPlaylistVideoEntity(insertInto: context)
        playlist.addToPlaylistVideos(pe)
        try? context.save()
        return .success(())
    }

    /// 새로운 재생목록을 생성하고 비디오를 추가합니다.
    /// - Parameters:
    ///   - name: 생성할 재생목록 이름
    ///   - video: 추가할 PixabayResponse.Hit 모델
    /// - Returns: 성공 시 `.success(())`, 이미 존재하면 `.failure(Error)` 반환
    @discardableResult
    func createPlaylist(named name: String, with video: PixabayResponse.Hit) -> Result<Void, Error> {
        guard !PlaylistEntity.isExist(name) else {
            return .failure(NSError(
                domain: "VideoDataService",
                code: 3,
                userInfo: [NSLocalizedDescriptionKey: "이미 존재하는 재생 목록 이름입니다"]
            ))
        }

        let playlist = PlaylistEntity(context: context)
        playlist.name       = name
        playlist.createdAt  = Date()
        playlist.isBookmark = false

        let pe = video.mapToPlaylistVideoEntity(insertInto: context)
        playlist.addToPlaylistVideos(pe)
        try? context.save()
        return .success(())
    }
}

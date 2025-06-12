//
//  CoreDataService+Dummy.swift
//  Media
//
//  Created by 김건우 on 6/7/25.
//

import Foundation

extension CoreDataService {
    
    /// 디버그 모드에서 (모든 기존 데이터를 삭제하고) 더미 데이터를 생성합니다.
    func generateDummy() {
        #if DEBUG
        generatePlaylistEntity()
        generatePlaybackHistoryEntity()
        #endif
    }
    
    /// PixabayResponse의 목 데이터를 기반으로 PlaybackHistoryEntity 배열을 생성하여 Core Data에 삽입합니다.
    ///
    /// - Returns: 생성된 PlaybackHistoryEntity 객체 배열입니다.
    @discardableResult
    private func generatePlaybackHistoryEntity() -> [PlaybackHistoryEntity] {
        return PixabayResponse.mock.hits.map {
            let entity = $0.mapToPlaybackHistoryEntity(insertInto: self.viewContext)
            let randomInterval = TimeInterval.random(in: -10...10) * 86_400
            entity.createdAt = Date().addingTimeInterval(randomInterval)
            return entity
        }
    }

    /// 고정된 이름의 재생목록과 PixabayResponse의 목 데이터를 기반으로 PlaylistEntity 배열을 생성하여 Core Data에 삽입합니다.
    ///
    /// - Returns: 생성된 PlaylistEntity 객체 배열입니다.
    @discardableResult
    private func generatePlaylistEntity() -> [PlaylistEntity] {
        let names = ["북마크를 표시한 재생목록", "재생목록1", "재생목록2", "재생목록3"]

        let playlists: [PlaylistEntity] = names.map {
            let playlist = PlaylistEntity(context: self.viewContext)
            playlist.name = $0
            playlist.createdAt = Date().addingTimeInterval(86_400 * Double.random(in: -10...0))
            PixabayResponse.mock.hits.map {
                let video = $0.mapToPlaylistVideoEntity(insertInto: self.viewContext)
                playlist.addToPlaylistVideos(video)
            }
            return playlist
        }
        return playlists
    }
}

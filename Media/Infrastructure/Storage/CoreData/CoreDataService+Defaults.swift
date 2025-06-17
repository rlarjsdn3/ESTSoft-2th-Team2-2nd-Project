//
//  CoreDataService+Defaults.swift
//  Media
//
//  Created by 김건우 on 6/11/25.
//

import Foundation

typealias CoreDataString = CoreDataService.StaticString
extension CoreDataService {
    
    enum StaticString {
        static let bookmarkedPlaylistName = "Bookmarked Playlist"
    }
}

extension CoreDataService {

    /// 앱을 처음 실행할 때 기본 Core Data 엔터티를 추가합니다.
    ///
    /// `UserDefaultsService`의 `isFirstLaunch` 값이 `true`일 경우,
    /// 기본 재생 목록인 "북마크를 표시한 재생목록"을 생성하고 컨텍스트에 저장합니다.
    ///
    /// - Important: 이 메서드 호출 이후 `UserDefaultsService.shared.isFirstLaunch` 값을 반드시 `false`로 설정해야
    ///   중복 데이터 생성이 발생하지 않습니다.
    func initializeDefaultDataIfFirstRun() {
        let userDefaults = UserDefaultsService.shared
        if !userDefaults.hasCompletedInitialSetup {
            // 기본 플레이리스트('북마크로 표시된 재생목록') 엔터티 추가
            let _ = PlaylistEntity(
                name: CoreDataString.bookmarkedPlaylistName,
                isBookmark: true,
                insertInto: viewContext
            )
            saveContext()
        }
        userDefaults.hasCompletedInitialSetup = true
    }
}

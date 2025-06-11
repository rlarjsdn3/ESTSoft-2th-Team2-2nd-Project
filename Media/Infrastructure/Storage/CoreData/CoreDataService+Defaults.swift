//
//  CoreDataService+Defaults.swift
//  Media
//
//  Created by 김건우 on 6/11/25.
//

import Foundation

extension CoreDataService {

    /// 앱을 처음 켜면 넣을 기본 데이터
    /// 반드시 함수 바깥에서 `isFirstLaunch` 키를 false로 변경해야 함
    func initializeDefaultDataIfFirstRun() {
        if UserDefaultsService.shared.isFirstLaunch {
            // 기본 플레이리스트('북마크로 표시된 재생목록') 엔터티 추가
            let _ = PlaylistEntity(name: "북마크를 표시한 재생목록", insertInto: viewContext)
            saveContext()
        }
    }
}

//
//  PlaylistEntity+Extension.swift
//  Media
//
//  Created by 김건우 on 6/11/25.
//

import Foundation

extension PlaylistEntity {
    
    /// 주어진 이름을 가진 재생 목록이 Core Data에 존재하는지 여부를 반환합니다.
    ///
    /// 내부적으로 모든 `PlaylistEntity`를 가져온 후, 해당 이름과 일치하는 엔터티가 있는지 확인합니다.
    ///
    /// - Parameter name: 존재 여부를 확인할 재생 목록의 이름입니다.
    /// - Returns: 동일한 이름을 가진 재생 목록이 하나라도 존재하면 `true`, 그렇지 않으면 `false`를 반환합니다.
    static func isExist(_ name: String) -> Bool {
        if let entities: [PlaylistEntity] = try? CoreDataService.shared.fetch() {
            return entities.contains(where: { $0.name == name })
        }
        return false
    }
}

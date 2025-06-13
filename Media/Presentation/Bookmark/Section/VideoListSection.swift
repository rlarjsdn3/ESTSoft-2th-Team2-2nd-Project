//
//  PlaylistSection.swift
//  Media
//
//  Created by 김건우 on 6/9/25.
//

import Foundation

enum VideoList {

    /// 컬렉션 뷰의 섹션 유형을 정의하는 열거형입니다.
    enum SectionType: Int, CaseIterable {
        /// 재생 목록 섹션
        case playlist
        /// 재생 기록 섹션
        case playback
    }

    /// 컬렉션 뷰의 섹션 정보를 나타내는 구조체입니다.
    struct Section: Hashable {
        /// 섹션의 유형입니다.
        let type: SectionType
        /// 섹션의 이름입니다. 선택적입니다.
        let name: String?
        
        /// 섹션을 초기화합니다.
        /// - Parameters:
        ///   - type: 섹션 유형
        ///   - name: 섹션 이름 (옵션)
        init(type: SectionType, name: String? = nil) {
            self.type = type
            self.name = name
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(type)
            hasher.combine(name)
        }
    }

    /// 컬렉션 뷰의 셀 항목을 나타내는 열거형입니다.
    enum Item: Hashable {
        /// 재생 목록에 포함된 비디오 항목
        case playlist(PlaylistVideoEntity)
        /// 재생 기록 항목
        case playback(PlaybackHistoryEntity)

        func hash(into hasher: inout Hasher) {
            switch self {
            case .playlist(let entity):
                hasher.combine(entity.objectID)
            case .playback(let entity):
                hasher.combine(entity.objectID)
            }
        }

        static func == (lhs: Item, rhs: Item) -> Bool {
            switch (lhs, rhs) {
            case (.playlist(let a), .playlist(let b)):
                return a.objectID == b.objectID
            case (.playback(let a), .playback(let b)):
                return a.objectID == b.objectID
            default:
                return false
            }
        }
    }
}

//
//  BookmarkSectionType.swift
//  Media
//
//  Created by 김건우 on 6/9/25.
//

import UIKit
import CoreData

enum Bookmark {
    
    /// 컬렉션 뷰 섹션의 유형을 정의하는 열거형입니다.
    enum SectionType: Int, CaseIterable {
        /// 재생 기록 섹션
        case playback
        /// 재생 목록 섹션
        case playlist
    }

    /// 컬렉션 뷰 섹션을 나타내는 구조체입니다.
    struct Section: Hashable {
        /// 섹션의 유형입니다.
        let type: SectionType
    }

    /// 컬렉션 뷰 셀 항목을 나타내는 열거형입니다.
    enum Item: Hashable {
        /// 재생 기록 항목
        case playback(PlaybackHistoryEntity)
        /// 재생 목록 항목
        case playlist(PlaylistEntity)
        /// 재생 목록 추가 버튼 항목
        case addPlaylist
        
        func hash(into hasher: inout Hasher) {
            switch self {
            case .playback(let entity):
                hasher.combine(entity.id)
            case .playlist(let entity):
                hasher.combine(entity.id)
            case .addPlaylist:
                hasher.combine("addPlaylist")
            }
        }

        static func == (lhs: Item, rhs: Item) -> Bool {
            switch (lhs, rhs) {
            case (.playback(let a), .playback(let b)):
                return a.id == b.id
            case (.playlist(let a), .playlist(let b)):
                return a.id == b.id
            case (.addPlaylist, .addPlaylist):
                return true
            default:
                return false
            }
        }
    }
}

extension Bookmark.SectionType {

    func buildLayout(for environment: any NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        switch self {
        case .playback:
            buildHistoryLayout(for: environment)
        case .playlist:
            buildPlaylistLayout(for: environment)
        }
    }

    private func buildHistoryLayout(for environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupWidthDimension: NSCollectionLayoutDimension = if environment.isHorizontalSizeClassCompact {
            .fractionalWidth(0.9)
        } else {
            switch environment.container.effectiveContentSize.width {
            case 500..<1050:  .fractionalWidth(0.44)  // 아이패드 세로 모드
            default:          .fractionalWidth(0.40)  // 아이패드 가로 모드
            }
        }
        let groupHeightDimension: NSCollectionLayoutDimension = if environment.isHorizontalSizeClassCompact {
            .fractionalWidth(0.76)
        } else {
            switch environment.container.effectiveContentSize.width {
            case 500..<1050:  .fractionalWidth(0.36)  // 아이패드 세로 모드
            default:          .fractionalWidth(0.30)  // 아이패드 가로 모드
            }
        }
        let groupSize = NSCollectionLayoutSize(
            widthDimension: groupWidthDimension,
            heightDimension: groupHeightDimension
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item]
        )
        group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 20, trailing: 0)

        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(50)
        )
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: HeaderReusableView.id,
            alignment: .top
        )
        header.pinToVisibleBounds = true

        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPaging
        section.boundarySupplementaryItems = [header]

        return section
    }

    private func buildPlaylistLayout(for environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        
        let itemWidthDimension: NSCollectionLayoutDimension = environment.isHorizontalSizeClassCompact
        ? .fractionalWidth(0.5) : .fractionalWidth(0.33)

        let itemSize = NSCollectionLayoutSize(
            widthDimension: itemWidthDimension,
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let colmnCount = environment.isHorizontalSizeClassCompact ? 2 : 3
        let groupHeightDimension: NSCollectionLayoutDimension = environment.isHorizontalSizeClassCompact
        ? .fractionalWidth(0.4) : .fractionalWidth(0.24)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: groupHeightDimension
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            repeatingSubitem: item,
            count: colmnCount
        )
        group.interItemSpacing = .flexible(10)
        group.contentInsets = .init(top: 10, leading: 10, bottom: 10, trailing: 10)

        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(50)
        )
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: HeaderReusableView.id,
            alignment: .top
        )
        header.pinToVisibleBounds = true

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 4 // 임시 값
        section.boundarySupplementaryItems = [header]
        return section
    }
}

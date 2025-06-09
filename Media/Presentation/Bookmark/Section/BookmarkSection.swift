//
//  BookmarkSectionType.swift
//  Media
//
//  Created by 김건우 on 6/9/25.
//

import UIKit

enum Bookmark {

    enum Section: Int, CaseIterable {
        case history
        case playlist
    }

    enum Item: Hashable {
        case history(PlaybackHistoryEntity)
        case playlist(PlaylistEntity)

        func hash(into hasher: inout Hasher) {
            switch self {
            case .history(let entity):
                hasher.combine(entity.id)
            case .playlist(let entity):
                hasher.combine(entity.id)
            }
        }
    }
}


extension Bookmark.Section {

    func buildLayout(for environment: any NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        switch self {
        case .history:
            buildHistoryLayout(for: environment)
        case .playlist:
            buildPlaylistLayout(for: environment)
        }
    }

    private func buildHistoryLayout(for environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        // 아이폰이라면 'true', 아이패드라면 'false'
        let isHorizontalSizeClassCompact = environment.traitCollection.horizontalSizeClass == .compact

        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0), // 임시 값
            heightDimension: .fractionalHeight(1.0) // 임시 값
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .estimated(350), // 임시 값
            heightDimension: .estimated(250) // 임시 값
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item]
        )

        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(44) // 임시 값
        )
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: ColorCollectiorReusableView.id,
            alignment: .top
        )
        header.pinToVisibleBounds = true

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 8
        section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
        section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
        section.boundarySupplementaryItems = [header]

        return section
    }

    private func buildPlaylistLayout(for environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        // 아이폰이라면 'true', 아이패드라면 'false'
        let isHorizontalSizeClassCompact = environment.traitCollection.horizontalSizeClass == .compact

        let itemWidthDimension: NSCollectionLayoutDimension = isHorizontalSizeClassCompact
        ? .fractionalWidth(0.5) : .fractionalWidth(0.33)
        let itemHeightDeimension: NSCollectionLayoutDimension = isHorizontalSizeClassCompact
        ? .fractionalWidth(0.33) : .fractionalWidth(0.33) // 임시 값

        let itemSize = NSCollectionLayoutSize(
            widthDimension: itemWidthDimension,
            heightDimension: itemHeightDeimension
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let coulmnCount = isHorizontalSizeClassCompact ? 2 : 3
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalWidth(0.33) // 임시 값
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitem: item,
            count: coulmnCount
        )
        group.interItemSpacing = .fixed(8)

        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(44) // 임시 값
        )
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: ColorCollectiorReusableView.id,
            alignment: .top
        )
        header.pinToVisibleBounds = true

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 4
        section.contentInsets = .init(top: 8, leading: 8, bottom: 8, trailing: 8)
        section.boundarySupplementaryItems = [header]
        return section
    }
}

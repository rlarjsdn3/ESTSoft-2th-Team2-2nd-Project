//
//  BookmarkSectionType.swift
//  Media
//
//  Created by 김건우 on 6/9/25.
//

import UIKit

enum Bookmark {
    
    /// <#Description#>
    enum SectionType: Int, CaseIterable {
        ///
        case history
        ///
        case playlist
    }

    struct Section: Hashable {
        ///
        let type: SectionType
    }

    enum Item: Hashable {
        ///
        case history(PlaybackHistoryEntity)
        ///
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


extension Bookmark.SectionType {

    func buildLayout(for environment: any NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        switch self {
        case .history:
            buildHistoryLayout(for: environment)
        case .playlist:
            buildPlaylistLayout(for: environment)
        }
    }

    private func buildHistoryLayout(for environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let isHorizontalSizeClassCompact = environment.traitCollection.horizontalSizeClass == .compact

        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0)

        let groupWidthDimension: NSCollectionLayoutDimension = isHorizontalSizeClassCompact
        ? .fractionalWidth(0.9) : .fractionalWidth(0.42)
        let groupHeightDimension: NSCollectionLayoutDimension = isHorizontalSizeClassCompact
        ? .fractionalWidth(0.75) : .fractionalWidth(0.36)
        let groupSize = NSCollectionLayoutSize(
            widthDimension: groupWidthDimension,
            heightDimension: groupHeightDimension
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item]
        )
        group.interItemSpacing = .flexible(10)

        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(44)
        )
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: HeaderReusableView.id,
            alignment: .top
        )
        header.pinToVisibleBounds = true

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 8
        section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
        section.boundarySupplementaryItems = [header]

        return section
    }

    private func buildPlaylistLayout(for environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let isHorizontalSizeClassCompact = environment.traitCollection.horizontalSizeClass == .compact

        let itemWidthDimension: NSCollectionLayoutDimension = isHorizontalSizeClassCompact
        ? .fractionalWidth(0.5) : .fractionalWidth(0.33)

        let itemSize = NSCollectionLayoutSize(
            widthDimension: itemWidthDimension,
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let colmnCount = isHorizontalSizeClassCompact ? 2 : 3
        let groupHeightDimension: NSCollectionLayoutDimension = isHorizontalSizeClassCompact
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
            heightDimension: .estimated(44)
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

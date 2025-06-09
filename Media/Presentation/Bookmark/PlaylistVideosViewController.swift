//
//  PlaylistVideosViewController.swift
//  Media
//
//  Created by 김건우 on 6/9/25.
//

import UIKit

final class PlaylistVideosViewController: StoryboardViewController {

    typealias PlaylistDiffableDataSource = UICollectionViewDiffableDataSource<VideoList.Section, VideoList.Item>

    var playlistVideos: [PlaylistVideoEntity]?
    private let coreDataService = CoreDataService.shared

    private var dataSource: PlaylistDiffableDataSource? = nil

    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupDataSource()
    }
    
    override func setupAttributes() {
        super.setupAttributes()
        
        self.collectionView.collectionViewLayout = createCompositionalLayout()
    }
    
    private func createCompositionalLayout() -> UICollectionViewCompositionalLayout {
        let sectionProvider: UICollectionViewCompositionalLayoutSectionProvider = { _, environment in
            let isHorizontalSizeClassCompact = environment.traitCollection.horizontalSizeClass == .compact
            
            let itemWidthDimension: NSCollectionLayoutDimension = isHorizontalSizeClassCompact
            ? .fractionalWidth(1.0) : .fractionalWidth(0.33)
            let itemSize = NSCollectionLayoutSize(
                widthDimension: itemWidthDimension, // 임시 값
                heightDimension: .estimated(200) // 임시 값
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            let columnCount = isHorizontalSizeClassCompact ? 1 : 3
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0), // 임시 값
                heightDimension: .estimated(200) // 임시 값
            )
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: groupSize,
                repeatingSubitem: item,
                count: columnCount
            )
            group.interItemSpacing = .flexible(8) // 임시 값

            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 8 // 임시 값
            return section
        }
        
        return UICollectionViewCompositionalLayout(sectionProvider: sectionProvider)
    }
}

// MARK: - Setup DataSource

extension PlaylistVideosViewController {
    
    private func setupDataSource() {
        // 임시 셀 등록
        let cellRagistration = UICollectionView.CellRegistration<HistoryCollectionViewCell, VideoList.Item> { cell, indexPath, item in
            cell.backgroundColor = UIColor.random
        }

        // 임시 데이터 소스 코드
        dataSource = PlaylistDiffableDataSource(collectionView: collectionView) { collectionView, indexPath, item in
            return collectionView.dequeueConfiguredReusableCell(
                using: cellRagistration,
                for: indexPath,
                item: item
            )
        }

        applySnapshot()
    }
    
    private func applySnapshot() {
        guard let playlistVideos = playlistVideos else { return }
        let playlistItems: [VideoList.Item] = playlistVideos.map { VideoList.Item.playlist($0) }

        var snapshot = NSDiffableDataSourceSnapshot<VideoList.Section, VideoList.Item>()
        let playlistSection = VideoList.Section(type: .playlist)
        snapshot.appendSections([playlistSection])
        snapshot.appendItems(playlistItems, toSection: playlistSection)
        dataSource?.apply(snapshot, animatingDifferences: true)
    }
}


// MARK: - UICollectionViewDelegate

extension PlaylistVideosViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        didHighlightItemAt indexPath: IndexPath
    ) {
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        didUnhighlightItemAt indexPath: IndexPath
    ) {
    }
}

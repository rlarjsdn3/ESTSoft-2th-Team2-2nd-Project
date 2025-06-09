//
//  BookmarkViewController.swift
//  Media
//
//  Created by 김건우 on 6/9/25.
//

import UIKit
import CoreData

final class BookmarkViewController: StoryboardViewController {

    private typealias BookmarkDiffableDataSource = UICollectionViewDiffableDataSource<Bookmark.Section, UIColorItem>

    private var dataSource: BookmarkDiffableDataSource? = nil
    @IBOutlet weak var collectionView: UICollectionView!

    private var playbackFetchedResultsController: NSFetchedResultsController<PlaybackHistoryEntity>? = nil
    private var playlistFetchedResultsController: NSFetchedResultsController<PlaylistEntity>? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        setupDataSource()
        setupFetchedResultsController()
    }

    override func setupAttributes() {
        super.setupAttributes()

        self.collectionView.collectionViewLayout = createCompositionalLayout()
    }

    private func createCompositionalLayout() -> UICollectionViewCompositionalLayout {
        let sectionProvider: UICollectionViewCompositionalLayoutSectionProvider = { sectionIndex, environment in
            guard let section = Bookmark.Section(rawValue: sectionIndex) else { return nil }

            return section.buildLayout(for: environment)
        }
        return UICollectionViewCompositionalLayout(sectionProvider: sectionProvider)
    }
}

extension BookmarkViewController {

    private func setupDataSource() {
        // 임시 셀 등록 코드
        let cellRagistration = UICollectionView.CellRegistration<ColorCollectionViewCell, UIColorItem> { cell, indexPath, item in
            cell.backgroundColor = UIColor.random
        }

        // 임시 헤더 등록 코드
        let headerRegistration = UICollectionView.SupplementaryRegistration<ColorCollectiorReusableView>(elementKind: ColorCollectiorReusableView.id) { supplementaryView, elementKind, indexPath in
            supplementaryView.backgroundColor = UIColor.random
        }

        // 임시 데이터 소스 코드
        dataSource = BookmarkDiffableDataSource(collectionView: collectionView) { collectionView, indexPath, item in
            return collectionView.dequeueConfiguredReusableCell(
                using: cellRagistration,
                for: indexPath,
                item: item
            )
        }
        // 임시 데이터 소스 코드
        dataSource?.supplementaryViewProvider = { collectionView, kind, indexPath in
            return collectionView.dequeueConfiguredReusableSupplementary(
                using: headerRegistration,
                for: indexPath)
        }

        applySnapshot()
    }

    private func applySnapshot() {
        // 임시 스냅샷 적용 코드
        var snapshot = NSDiffableDataSourceSnapshot<Bookmark.Section, UIColorItem>()
        snapshot.appendSections([.history])
        snapshot.appendItems([.init(), .init(), .init()], toSection: .history)
        snapshot.appendSections([.playlist])
        snapshot.appendItems([.init(), .init(), .init(),.init(), .init(), .init(),.init(), .init(), .init()], toSection: .playlist)
        dataSource?.apply(snapshot, animatingDifferences: false)
    }

    private func setupFetchedResultsController() {
        
    }
}



// 임시 셀 아이템 코드

struct UIColorItem: Hashable {
    let id = UUID()
    let color = UIColor.random
}

fileprivate extension UIColor {

    static var random: UIColor {
        let hue = CGFloat.random(in: 0...1)
        let saturation = CGFloat.random(in: 0.5...1)
        let brightness = CGFloat.random(in: 0.5...1)
        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1.0)
    }
}

//
//  BookmarkViewController.swift
//  Media
//
//  Created by 김건우 on 6/9/25.
//

import UIKit
import CoreData

final class BookmarkViewController: StoryboardViewController {

    private typealias BookmarkDiffableDataSource = UICollectionViewDiffableDataSource<Bookmark.Section, Bookmark.Item>

    private var dataSource: BookmarkDiffableDataSource? = nil
    @IBOutlet weak var collectionView: UICollectionView!

    private var playbackFetchedResultsController: NSFetchedResultsController<PlaybackHistoryEntity>? = nil
    private var playlistFetchedResultsController: NSFetchedResultsController<PlaylistEntity>? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        setupFetchedResultsController()
        setupDataSource()
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
        let historyCellRagistration = UICollectionView.CellRegistration<HistoryCollectionViewCell, Bookmark.Item> { cell, indexPath, item in
            cell.backgroundColor = UIColor.random
            cell.label.text = "\(indexPath) history"
        }

        let playlistCellRagistration = UICollectionView.CellRegistration<PlaylistCollectionViewCell, Bookmark.Item> { cell, indexPath, item in
            cell.backgroundColor = UIColor.random
            cell.label.text = "\(indexPath) playlist"
        }

        // 임시 헤더 등록 코드
        let headerRegistration = UICollectionView.SupplementaryRegistration<ColorCollectiorReusableView>(elementKind: ColorCollectiorReusableView.id) { supplementaryView, elementKind, indexPath in
            supplementaryView.backgroundColor = UIColor.random
        }

        // 임시 데이터 소스 코드
        dataSource = BookmarkDiffableDataSource(collectionView: collectionView) { collectionView, indexPath, item in
            guard let section = Bookmark.Section(rawValue: indexPath.section) else { return UICollectionViewCell() }

            switch section {
            case .history:
                return collectionView.dequeueConfiguredReusableCell(
                    using: historyCellRagistration,
                    for: indexPath,
                    item: item
                )

            case .playlist:
                return collectionView.dequeueConfiguredReusableCell(
                    using: playlistCellRagistration,
                    for: indexPath,
                    item: item
                )
            }
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
        var snapshot = NSDiffableDataSourceSnapshot<Bookmark.Section, Bookmark.Item>()

        if let history = playbackFetchedResultsController?.fetchedObjects {
            let items = history.map { Bookmark.Item.history($0) }
            snapshot.appendSections([.history])
            snapshot.appendItems(items, toSection: .history)
        }

        if let playlists = playlistFetchedResultsController?.fetchedObjects {
            let items = playlists.map { Bookmark.Item.playlist($0) }
            snapshot.appendSections([.playlist])
            snapshot.appendItems(items, toSection: .playlist)
        }

        dataSource?.apply(snapshot, animatingDifferences: true)
    }

    private func setupFetchedResultsController() {
        let viewContext = CoreDataService.shared.viewContext

        let playlistFetchRequest = PlaylistEntity.fetchRequest().apply {
            $0.sortDescriptors = [NSSortDescriptor(keyPath: \PlaylistEntity.createdAt, ascending: true)]
        }
        playlistFetchedResultsController = NSFetchedResultsController(
            fetchRequest: playlistFetchRequest,
            managedObjectContext: viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        playlistFetchedResultsController?.delegate = self

        let playbackFetchRequest = PlaybackHistoryEntity.fetchRequest().apply {
            $0.sortDescriptors = [NSSortDescriptor(keyPath: \PlaybackHistoryEntity.createdAt, ascending: false)]
        }
        playbackFetchedResultsController = NSFetchedResultsController(
            fetchRequest: playbackFetchRequest,
            managedObjectContext: viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        playbackFetchedResultsController?.delegate = self

        do {
            try playlistFetchedResultsController?.performFetch()
            try playbackFetchedResultsController?.performFetch()
        } catch {
            print("FetchedResultsController performFetch error: \(error)")
        }
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension BookmarkViewController: NSFetchedResultsControllerDelegate {

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        applySnapshot()
    }
}


// MARK: - UICollectionViewDelegate

extension BookmarkViewController: UICollectionViewDelegate {

    func collectionView(
        _ collectionView: UICollectionView,
        didHighlightItemAt indexPath: IndexPath
    ) {
        guard let cell = collectionView.cellForItem(at: indexPath) else { return }
        adjustAnimatedScale(for: cell, scale: 0.95)
    }

    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) else { return }
        adjustAnimatedScale(for: cell)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        guard let cell = collectionView.cellForItem(at: indexPath) else { return }
        adjustAnimatedScale(for: cell)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        didDeselectItemAt indexPath: IndexPath
    ) {
        guard let cell = collectionView.cellForItem(at: indexPath) else { return }
        adjustAnimatedScale(for: cell)
    }

    private func adjustAnimatedScale(for cell: UICollectionViewCell, scale: CGFloat = 1.0) {
        UIView.animate(withDuration: 0.1) {
            cell.transform = CGAffineTransform(
                scaleX: scale,
                y: scale
            )
        }
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

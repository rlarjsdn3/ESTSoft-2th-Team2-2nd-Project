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

    private let userDefaultsService = UserDefaultsService.shared
    private let coreDataService = CoreDataService.shared
    
    private var dataSource: BookmarkDiffableDataSource? = nil

    @IBOutlet weak var navigationBar: NavigationBar!
    @IBOutlet weak var collectionView: UICollectionView!

    private var playbackFetchedResultsController: NSFetchedResultsController<PlaybackHistoryEntity>? = nil
    private var playlistFetchedResultsController: NSFetchedResultsController<PlaylistEntity>? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        setupFetchedResultsController()
        setupDataSource()
    }

    override func prepare(
        for segue: UIStoryboardSegue,
        sender: Any?
    ) {
        if let playlistVC = segue.destination as? PlaylistVideosViewController {
            guard let indexPath = sender as? IndexPath,
                  case let .playlist(entity) = dataSource?.itemIdentifier(for: indexPath),
                  let playlistVideos = entity.playlistVideos?.allObjects as? [PlaylistVideoEntity] else {
                return
            }
            playlistVC.videos = .playlist(playlistVideos)
        }
    }

    override func setupAttributes() {
        super.setupAttributes()

        var title: String = "Bookmark"
        if let username = userDefaultsService.userName {
            title = "\(username)'s Bookmark"
        }
        navigationBar.configure(
            title: title,
            isLeadingAligned: true
        )

        collectionView.collectionViewLayout = createCompositionalLayout()
    }

    private func createCompositionalLayout() -> UICollectionViewCompositionalLayout {
        let sectionProvider: UICollectionViewCompositionalLayoutSectionProvider = { sectionIndex, environment in
            guard let section = Bookmark.SectionType(rawValue: sectionIndex) else { return nil }

            return section.buildLayout(for: environment)
        }
        return UICollectionViewCompositionalLayout(sectionProvider: sectionProvider)
    }
}

// MARK: - Setup DataSource

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
            guard let section = Bookmark.SectionType(rawValue: indexPath.section) else { return UICollectionViewCell() }

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
            let historySection = Bookmark.Section(type: .history)
            snapshot.appendSections([historySection])
            snapshot.appendItems(items, toSection: historySection)
        }

        if let playlists = playlistFetchedResultsController?.fetchedObjects {
            let items = playlists.map { Bookmark.Item.playlist($0) }
            let playlistSection = Bookmark.Section(type: .playlist)
            snapshot.appendSections([playlistSection])
            snapshot.appendItems(items, toSection: playlistSection)
        }

        dataSource?.apply(snapshot, animatingDifferences: true)
    }

    private func setupFetchedResultsController() {
        let viewContext = coreDataService.viewContext

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
        adjustAnimatedOpacity(for: cell)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        didUnhighlightItemAt indexPath: IndexPath
    ) {
        guard let cell = collectionView.cellForItem(at: indexPath) else { return }
        adjustAnimatedOpacity(for: cell, opacity: 1.0)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        performSegue(
            withIdentifier: "navigateToPlaylistVideos",
            sender: indexPath
        )
    }

    func collectionView(
        _ collectionView: UICollectionView,
        contextMenuConfigurationForItemsAt indexPaths: [IndexPath],
        point: CGPoint
    ) -> UIContextMenuConfiguration? {
        guard let indexPath = indexPaths.first,
              let section = Bookmark.SectionType(rawValue: indexPath.section),
              section != .history else {
            return nil }

        return UIContextMenuConfiguration(
            identifier: nil,
            previewProvider: nil
        ) { suggestedActions in
            let renameAction = self.renamePlaylistNameAction(for: indexPath)
            let deleteAction = self.deletePlaylistAction(for: indexPath)
            return UIMenu(title: "", children: [renameAction, deleteAction])
        }
    }
}

// MARK: - Bookmark Extension

extension BookmarkViewController {
    
    private func adjustAnimatedOpacity(
        for cell: UICollectionViewCell,
        opacity: CGFloat = 0.75
    ) {
        UIView.animate(withDuration: 0.1) {
            cell.layer.opacity = Float(opacity)
        }
    }
    
    private func renamePlaylistNameAction(for indexPath: IndexPath) -> UIAction {
        return UIAction(
            title: "Rename Playlist",
            image: UIImage(systemName: "square.and.pencil")
        ) { _ in
            guard let entity = self.playListEntityFromDatasource(for: indexPath) else { return }
            
            self.showTextFieldAlert(
                "Rename Playlist",
                message: "Please enter a new name.",
                defaultText: entity.name,
                placeholder: "New name",
                onConfirm: { (_, newName) in
                    self.coreDataService.update(entity, by: \.name, to: newName)
                },
                onCancel: { _ in
                }
            )
        }
    }

    private func deletePlaylistAction(for indexPath: IndexPath) -> UIAction {
        return UIAction(
            title: "Delete Playlist",
            image: UIImage(systemName: "trash"),
            attributes: .destructive
        ) { _ in
            guard let entity = self.playListEntityFromDatasource(for: indexPath) else { return }
            
            self.showDeleteAlert(
                "Delete Playlist",
                message: "Are you sure you want to delete this playlist? This action cannot be undone.",
                onConfirm: { _ in
                    self.coreDataService.delete(entity)
                },
                onCancel: { _ in
                }
            )
        }
    }
    
    private func playListEntityFromDatasource(for indexPath: IndexPath) -> PlaylistEntity? {
        guard let item = self.dataSource?.itemIdentifier(for: indexPath),
              case let .playlist(entity) = item  else {
            return nil
        }
        return entity
    }
}


// 임시 색상 코드
extension UIColor {

    static var random: UIColor {
        let hue = CGFloat.random(in: 0...1)
        let saturation = CGFloat.random(in: 0.5...1)
        let brightness = CGFloat.random(in: 0.5...1)
        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1.0)
    }
}

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
        if let playlistVC = segue.destination as? VideoListViewController {
            if let item = sender as? Bookmark.Item {
                guard case let .playlist(playlistEntity) = item,
                      let playlistVideos = playlistEntity.playlistVideos?.allObjects as? [PlaylistVideoEntity] else {
                    return
                }
                playlistVC.videos = .playlist(playlistVideos)
            } else {
                guard let playbackVideos = playbackFetchedResultsController?.fetchedObjects else { return }
                playlistVC.videos = .playback(playbackVideos)
            }
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
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 16

        return UICollectionViewCompositionalLayout(sectionProvider: sectionProvider, configuration: config)
    }
}

// MARK: - Setup DataSource

extension BookmarkViewController {

    private func setupDataSource() {
        // 임시 셀 등록 코드
        let historyCellRagistration = UICollectionView.CellRegistration<VideoCell, Bookmark.Item>(cellNib: VideoCell.nib) { cell, indexPath, item in
            if case .history(let playback) = item {
                guard let thumbnailUrl = playback.video?.medium.thumbnail else { return }
                let viewModel = VideoCellViewModel(
                    title: playback.tags,
                    viewCountText: String(playback.views),
                    durationText: String(playback.duration),
                    thumbnailURL: thumbnailUrl,
                    profileImageURL: playback.userImageUrl,
                    likeCountText: String(playback.likes),
                    tags: playback.tags
                )
                cell.configure(with: viewModel)
            }
        }

        let playlistCellRagistration = UICollectionView.CellRegistration<SmallVideoCell, Bookmark.Item>(cellNib: SmallVideoCell.nib) { cell, indexPath, item in
            if case .playlist(let playlist) = item {
                guard let playlistName = playlist.name else { return }

                if let playlistVideoEntity = (playlist.playlistVideos?.allObjects.first as? PlaylistVideoEntity),
                   let thumbnailUrl = playlistVideoEntity.video?.medium.thumbnail {
                    cell.configure(url: thumbnailUrl, title: playlistName, isLast: false)
                } else {
                    cell.configure(title: playlistName, isLast: false)
                }
            }

            if case .addPlaylist = item {
                cell.configure(title: "", isLast: true)
            }
        }

        // 임시 헤더 등록 코드
        let headerRegistration = UICollectionView.SupplementaryRegistration<HeaderReusableView>(
            supplementaryNib: HeaderReusableView.nib,
            elementKind: HeaderReusableView.id
        ) { [weak self] supplementaryView, elementKind, indexPath in
            guard let section = self?.dataSource?.sectionIdentifier(for: indexPath.section) else { return }

            switch section.type {
            case .history:
                supplementaryView.delegate = self
                supplementaryView.configure(title: "재생 기록", hasEvent: true)
            case .playlist:
                supplementaryView.configure(title: "재생 목록")
            }
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
        #warning("김건우 -> 재생 기록이 하나도 없을 때 플레이스 8홀더 이미지 띄우기 / empty section")
        if let history = playbackFetchedResultsController?.fetchedObjects {
            let slicedItems = history.map { Bookmark.Item.history($0) }.prefix(10) // 재생 기록을 최근 10개까지만 출력하기
            let items = Array(slicedItems)
            let historySection = Bookmark.Section(type: .history)
            snapshot.appendSections([historySection])
            snapshot.appendItems(items, toSection: historySection)
        }

        if let playlists = playlistFetchedResultsController?.fetchedObjects {
            let items = playlists.map { Bookmark.Item.playlist($0) }
            let playlistSection = Bookmark.Section(type: .playlist)
            snapshot.appendSections([playlistSection])
            snapshot.appendItems(items, toSection: playlistSection)
            snapshot.appendItems([Bookmark.Item.addPlaylist], toSection: playlistSection)
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

    #warning("김건우 -> 시청 기록이 제대로 갱신되는지 다시 확인하기")
    func controller(
        _ controller: NSFetchedResultsController<any NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?
    ) {
        guard let dataSource = dataSource else { return }
        var currentSnapshot = dataSource.snapshot()

        switch type {
        case .insert:
            if let newPlaylist = anObject as? PlaylistEntity {
                currentSnapshot.insertItems([.playlist(newPlaylist)], beforeItem: .addPlaylist)
            }
        case .delete:
            if let oldPlaylist = anObject as? PlaylistEntity {
                currentSnapshot.deleteItems([.playlist(oldPlaylist)])
            }
        case .update:
            if let updatedPlaylist = anObject as? PlaylistEntity {
                let itemToReconfigure = Bookmark.Item.playlist(updatedPlaylist)
                if currentSnapshot.itemIdentifiers.contains(itemToReconfigure) {
                    currentSnapshot.reconfigureItems([itemToReconfigure])
                }
            }
        case .move:
            if let movedPlaylist = anObject as? PlaylistEntity {
                let itemToReconfigure = Bookmark.Item.playlist(movedPlaylist)
                if currentSnapshot.itemIdentifiers.contains(itemToReconfigure) {
                    currentSnapshot.reconfigureItems([itemToReconfigure])
                }
            }
        @unknown default:
            fatalError("can not handle change type")
        }

        dataSource.apply(currentSnapshot, animatingDifferences: true)
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
        guard let item = self.dataSource?.itemIdentifier(for: indexPath) else { return }

        if case .playlist = item {
            performSegue(
                withIdentifier: "navigateToPlaylistVideos",
                sender: item
            )
        }

        if case .addPlaylist = item {
            addPlaylistAction()
        }
    }

    #warning("김건우 -> 코드 리팩토링")
    func collectionView(
        _ collectionView: UICollectionView,
        contextMenuConfigurationForItemsAt indexPaths: [IndexPath],
        point: CGPoint
    ) -> UIContextMenuConfiguration? {
        guard let indexPath = indexPaths.first,
              let section = Bookmark.SectionType(rawValue: indexPath.section),
              let item = self.dataSource?.itemIdentifier(for: indexPath),
              let entity = self.playListEntityFromDatasource(for: indexPath) else {
            return nil
        }

        if section != .history, item != .addPlaylist, entity.name != "북마크를 표시한 재생목록" {
            return UIContextMenuConfiguration(
                identifier: nil,
                previewProvider: nil
            ) { suggestedActions in
                let renameAction = self.renamePlaylistAction(for: indexPath)
                let deleteAction = self.deletePlaylistAction(for: indexPath)
                return UIMenu(title: "", children: [renameAction, deleteAction])
            }
        }
        return nil
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

    private func addPlaylistAction() {
        showTextFieldAlert(
            "새로운 재생 목록 추가",
            message: "새로운 재생 목록 이름을 입력하세요.") { (action, newText) in
                if !PlaylistEntity.isExist(newText) {
                    let newPlaylist = PlaylistEntity(
                        name: newText,
                        insertInto: self.coreDataService.viewContext
                    )
                    self.coreDataService.insert(newPlaylist)
                } else {
                    Toast.makeToast("이미 존재하는 재생 목록 이름입니다.").present()
                }
        } onCancel: { action in
        }
    }

    private func renamePlaylistAction(for indexPath: IndexPath) -> UIAction {
        return UIAction(
            title: "재생 목록 이름 변경",
            image: UIImage(systemName: "square.and.pencil")
        ) { _ in
            guard let entity = self.playListEntityFromDatasource(for: indexPath) else { return }
            
            self.showTextFieldAlert(
                "재생 목록 이름 변경",
                message: "새로운 이름을 입력해 주세요.",
                defaultText: entity.name,
                placeholder: "새 이름",
                onConfirm: { (_, newName) in
                    if entity.name != newName, !PlaylistEntity.isExist(newName) {
                        self.coreDataService.update(entity, by: \.name, to: newName)
                    } else {
                        Toast.makeToast("이미 존재하는 재생 목록 이름입니다.").present()
                    }
                },
                onCancel: { _ in }
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


// MARK: - Header Delegate

extension BookmarkViewController: HeaderButtonDelegate {

    func HeaderButtonDidTap(_ headerView: UICollectionReusableView) {
        performSegue(
            withIdentifier: "navigateToPlaylistVideos",
            sender: nil
        )
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

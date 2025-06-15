//
//  BookmarkViewController.swift
//  Media
//
//  Created by 김건우 on 6/9/25.
//

import UIKit
import CoreData
import Combine

final class BookmarkViewController: StoryboardViewController {

    private typealias BookmarkDiffableDataSource = UICollectionViewDiffableDataSource<Bookmark.Section, Bookmark.Item>

    var observation: NSKeyValueObservation? = nil

    private let userDefaultsService = UserDefaultsService.shared
    private let coreDataService = CoreDataService.shared
    private let videoPlayerService = DefaultVideoPlayerService()

    private var dataSource: BookmarkDiffableDataSource? = nil

    @IBOutlet weak var navigationBar: NavigationBar!
    @IBOutlet weak var collectionView: UICollectionView!

    private var playbackFetchedResultsController: NSFetchedResultsController<PlaybackHistoryEntity>? = nil
    private var playlistFetchedResultsController: NSFetchedResultsController<PlaylistEntity>? = nil
    private var playlistVideoFetchedResultsController: NSFetchedResultsController<PlaylistVideoEntity>? = nil

    // MARK: - Lifecycles

    override func viewDidLoad() {
        super.viewDidLoad()

        setupFetchedResultsController()
        setupDataSource()
        registerUserDefaultsDidChangeNotification()
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
                
                playlistVC.videos = .playlist(
                    title: playlistEntity.name,
                    entities: playlistVideos,
                    isBookmark: playlistEntity.isBookmark
                )
            } else {
                guard let playbackVideos = playbackFetchedResultsController?.fetchedObjects else { return }
                playlistVC.videos = .playback(entities: playbackVideos)
            }
        }
    }

    override func setupAttributes() {
        super.setupAttributes()

        setupNaivgationBar()
        collectionView.apply {
            $0.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
            $0.collectionViewLayout = createCompositionalLayout()
        }
    }
    
    private func setupNaivgationBar() {
        guard let userName = userDefaultsService.userName else {
            navigationBar.configure(
                title: "Library",
                isLeadingAligned: true
            )
            return
        }

        navigationBar.configure(
            title: userName.isEmpty ? "Library" : "\(userName)'s Library",
            isLeadingAligned: true
        )
    }
    
    private func registerUserDefaultsDidChangeNotification() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleUserDefaultsDidChangeNotification),
            name: UserDefaults.didChangeNotification,
            object: nil
        )
    }
    
    @objc func handleUserDefaultsDidChangeNotification(_ notification: NotificationCenter) {
        setupNaivgationBar()
    }

    private func createCompositionalLayout() -> UICollectionViewCompositionalLayout {
        let sectionProvider: UICollectionViewCompositionalLayoutSectionProvider = { [weak self] sectionIndex, environment in
            guard let self = self,
                  let sectionIdentifier = self.dataSource?.snapshot().sectionIdentifiers[safe: sectionIndex]
            else { return nil }
            return sectionIdentifier.type.buildLayout(for: environment)
        }

        return UICollectionViewCompositionalLayout(sectionProvider: sectionProvider)
    }
}


// MARK: - Setup DataSource

extension BookmarkViewController {

    private func setupDataSource() {
        let playbackCellRagistration = createPlaybackCellRagistration()
        let playlistCellRagistration = createPlaylistCellRagistration()
        let headerRegistration = createSupplementaryViewRagistration()

        dataSource = BookmarkDiffableDataSource(collectionView: collectionView) { collectionView, indexPath, item in
            switch item {
            case .playback:
                return collectionView.dequeueConfiguredReusableCell(
                    using: playbackCellRagistration,
                    for: indexPath,
                    item: item
                )
            case .playlist, .addPlaylist:
                return collectionView.dequeueConfiguredReusableCell(
                    using: playlistCellRagistration,
                    for: indexPath,
                    item: item
                )
            }
        }
        dataSource?.supplementaryViewProvider = { collectionView, kind, indexPath in
            return collectionView.dequeueConfiguredReusableSupplementary(
                using: headerRegistration,
                for: indexPath
            )
        }

        applySnapshot()
    }

    private func createPlaybackCellRagistration() -> UICollectionView.CellRegistration<VideoCell, Bookmark.Item> {
        UICollectionView.CellRegistration<VideoCell, Bookmark.Item>(cellNib: VideoCell.nib) { [weak self] cell, indexPath, item in
            if case .playback(let playback) = item {
                guard let thumbnailUrl = playback.video?.medium.thumbnail else { return }
                let viewModel = VideoCellViewModel(
                    title: playback.user,
                    viewCount: Int(playback.views),
                    duration: Int(playback.duration),
                    thumbnailURL: thumbnailUrl,
                    profileImageURL: playback.userImageUrl,
                    likeCount: Int(playback.likes),
                    tags: playback.tags

                )
                cell.configure(with: viewModel)
                cell.configureMenu(onDeleteAction: { _ in
                    self?.coreDataService.delete(playback)
                })
                cell.setThumbnailImageCornerRadius(8)
                cell.onThumbnailTap = {
                    guard let self = self else { return }
                    self.videoPlayerService.playVideo(self, with: playback) { error in
                        guard let error = error else { return }

                        switch error {
                        case .notConnectedToInternet:
                            self.showAlert(
                                title: "No Internet Connection",
                                message: "Please check your internet connection.",
                                onPrimary: { _ in }
                            )
                        default:
                            break
                        }
                    }
                }
            }
        }
    }

    private func createPlaylistCellRagistration() -> UICollectionView.CellRegistration<SmallVideoCell, Bookmark.Item> {
        UICollectionView.CellRegistration<SmallVideoCell, Bookmark.Item>(cellNib: SmallVideoCell.nib) { cell, indexPath, item in
            if case .playlist(let playlist) = item {
                guard let totalVideos = playlist.playlistVideos?.count
                else { return }

                var viewModel: PlayListViewModel
                // 대표 이미지가 있다면 이미지와 함께 재생 목록 셀 구성
                if let playlistVideoEntity = playlist.playlistVideos?.allObjects.first as? PlaylistVideoEntity,
                   let thumbnailUrl = playlistVideoEntity.video?.medium.thumbnail {
                    viewModel = PlayListViewModel(
                        thumbnailUrl: thumbnailUrl,
                        userName: playlist.name,
                        total: totalVideos
                    )
                // 대표 이미지가 없다면 이미지를 빼고 재생 목록 셀 구성
                } else {
                    viewModel = PlayListViewModel(
                        userName: playlist.name,
                        total: totalVideos
                    )
                }
                cell.configure(viewModel)
            }

            if case .addPlaylist = item {
                cell.isLast = true
            }
        }
    }

    private func createSupplementaryViewRagistration() -> UICollectionView.SupplementaryRegistration<HeaderReusableView> {
        UICollectionView.SupplementaryRegistration<HeaderReusableView>(
            supplementaryNib: HeaderReusableView.nib,
            elementKind: HeaderReusableView.id
        ) { [weak self] supplementaryView, elementKind, indexPath in
            guard let section = self?.dataSource?.sectionIdentifier(for: indexPath.section) else { return }

            switch section.type {
            case .playback:
                supplementaryView.delegate = self
                supplementaryView.configure(title: "Playback History", hasEvent: true)
            case .playlist:
                supplementaryView.configure(title: "Playlist")
            }
        }

    }

    private func applySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Bookmark.Section, Bookmark.Item>()
        appendPlaybackItems(to: &snapshot)
        appendPlaylistItems(to: &snapshot)

        dataSource?.apply(snapshot, animatingDifferences: true)
    }

    private func appendPlaybackItems(to snapshot: inout NSDiffableDataSourceSnapshot<Bookmark.Section, Bookmark.Item>) {
        guard let playback = playbackFetchedResultsController?.fetchedObjects,
              !playback.isEmpty else { return }
        let items = playback.map { Bookmark.Item.playback($0) }.prefix(10)
        let section = Bookmark.Section(type: .playback)
        snapshot.appendSections([section])
        snapshot.appendItems(Array(items), toSection: section)
    }

    private func appendPlaylistItems(to snapshot: inout NSDiffableDataSourceSnapshot<Bookmark.Section, Bookmark.Item>) {
        guard let playlists = playlistFetchedResultsController?.fetchedObjects,
              !playlists.isEmpty else { return }
        let items = playlists.map { Bookmark.Item.playlist($0) } + [.addPlaylist]
        let section = Bookmark.Section(type: .playlist)
        snapshot.appendSections([section])
        snapshot.appendItems(items, toSection: section)
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

        let playlistVideoFetchRequest = PlaylistVideoEntity.fetchRequest().apply {
            $0.sortDescriptors = [NSSortDescriptor(keyPath: \PlaylistVideoEntity.id, ascending: true)]
        }
        playlistVideoFetchedResultsController = NSFetchedResultsController(
            fetchRequest: playlistVideoFetchRequest,
            managedObjectContext: viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        playlistVideoFetchedResultsController?.delegate = self

        do {
            try playlistFetchedResultsController?.performFetch()
            try playbackFetchedResultsController?.performFetch()
            try playlistVideoFetchedResultsController?.performFetch()
        } catch {
            print("FetchedResultsController performFetch error: \(error)")
        }
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension BookmarkViewController: NSFetchedResultsControllerDelegate {

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        applySnapshot()
    }

    func controller(
        _ controller: NSFetchedResultsController<any NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?
    ) {
        guard let dataSource = dataSource else { return }
        var snapshot = dataSource.snapshot()

        switch type {
        case .update:
            if let playlist = anObject as? PlaylistEntity {
                snapshot.reloadItems([Bookmark.Item.playlist(playlist)])
            }

        default:
            break
        }

        dataSource.apply(snapshot, animatingDifferences: true)
    }
}


// MARK: - UICollectionViewDelegate

extension BookmarkViewController: UICollectionViewDelegate {

    func collectionView(
        _ collectionView: UICollectionView,
        didHighlightItemAt indexPath: IndexPath
    ) {
        guard let cell = collectionView.cellForItem(at: indexPath) else { return }
        cell.animateOpacity()
    }

    func collectionView(
        _ collectionView: UICollectionView,
        didUnhighlightItemAt indexPath: IndexPath
    ) {
        guard let cell = collectionView.cellForItem(at: indexPath) else { return }
        cell.animateOpacity(1.0)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        guard let item = dataSource?.itemIdentifier(for: indexPath) else { return }

        switch item {
        case .playback:
            break
        case .playlist:
            performSegue(
                withIdentifier: "navigateToPlaylistVideos",
                sender: item
            )
        case .addPlaylist:
            showAddPlaylistAlert()
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        contextMenuConfigurationForItemsAt indexPaths: [IndexPath],
        point: CGPoint
    ) -> UIContextMenuConfiguration? {
        guard let indexPath = indexPaths.first,
              let section = self.dataSource?.snapshot().sectionIdentifiers[safe: indexPath.section],
              let item = self.dataSource?.itemIdentifier(for: indexPath),
              let entity = self.playListEntityFromDatasource(for: indexPath) else {
            return nil
        }

        // 항목이 '재생 기록' 섹션에 속하지 않으며
        // 항목이 '재생 목록 추가'이 아니며
        // 항목의 이름이 '북마크를 표시한 재생목록'이 아닐 때 ContextMenu 출력하기
        if section.type != .playback,
           item != .addPlaylist,
           entity.name != CoreDataString.bookmarkedPlaylistName {
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


// MARK: - HeaderButtonDelegate

extension BookmarkViewController: HeaderButtonDelegate {

    func headerButtonDidTap(_ headerView: UICollectionReusableView) {
        performSegue(
            withIdentifier: "navigateToPlaylistVideos",
            sender: nil
        )
    }
}



// MARK: - Extension

extension BookmarkViewController {

    private func showAddPlaylistAlert() {

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
            } onCancel: { _ in }
    }

    private func renamePlaylistAction(for indexPath: IndexPath) -> UIAction {

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
                    if entity.name != newName, !PlaylistEntity.isExist(newName) {
                        self.coreDataService.update(entity, by: \.name, to: newName)
                    } else {
                        Toast.makeToast("A playlist with this name already exists.").present()
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
                onCancel: { _ in }
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

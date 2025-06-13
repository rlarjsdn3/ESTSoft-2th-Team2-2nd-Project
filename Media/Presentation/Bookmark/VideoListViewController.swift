//
//  VideoListViewController.swift
//  Media
//
//  Created by 김건우 on 6/9/25.
//

import UIKit
import CoreData

/// 재생 기록 또는 재생 목록에 따라 표시할 비디오 목록의 유형을 나타내는 열거형입니다.
enum VideoListType {
    /// 재생 기록에 기반한 비디오 목록
    case playback(entities: [PlaybackHistoryEntity])
    /// 재생 목록에 기반한 비디오 목록
    case playlist(title: String, entities: [PlaylistVideoEntity])

//    case bookmark(entities: PlaylistEntity)
}

final class VideoListViewController: StoryboardViewController {

    typealias PlaylistDiffableDataSource = UICollectionViewDiffableDataSource<VideoList.Section, VideoList.Item>

    var videos: VideoListType?
    private let coreDataService = CoreDataService.shared

    private var dataSource: PlaylistDiffableDataSource? = nil

    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var navigationBar: NavigationBar!
    @IBOutlet weak var collectionView: UICollectionView!

    @IBOutlet weak var searchContainer: UIView!
    @IBOutlet weak var searchBar: UITextField!

    @IBOutlet weak var searchContainerTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var closeButtonTrailingConstraint: NSLayoutConstraint!

    private var playbackFetchedResultsController: NSFetchedResultsController<PlaybackHistoryEntity>? = nil
    private var playlistFetchedResultsController: NSFetchedResultsController<PlaylistEntity>? = nil
    private var playlistVideoFetchedResultsController: NSFetchedResultsController<PlaylistVideoEntity>? = nil

    // MARK: - Lifecycles
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupFetchedResultsController()
        setupDataSource()
        
        collectionView.collectionViewLayout = createCompositionalLayout()
    }
    
    @IBAction func didTapCloseButton(_ sender: Any) {
        searchBar.text = nil
        searchBar.endEditing(true)
        moveCloseButton(toRight: true)
        applySnapshot()
    }

    override func setupAttributes() {
        super.setupAttributes()

        setupNavigationBar()
        searchBar.apply {
            $0.delegate = self
            $0.placeholder = "검색어를 입력하세요."
        }
        closeButtonTrailingConstraint.constant = -50
    }

    #warning("김건우 -> 네비게이션 바 버튼 문제 해결하기")
    private func setupNavigationBar() {
        let leftIcon = UIImage(systemName: "arrow.left")
        let rightIcon = UIImage(systemName: "trash")
        switch videos {
        case .playback:
            navigationBar.configure(
                title: "재생 기록",
                leftIcon: leftIcon,
                leftIconTint: .mainLabelColor,
                rightIcon: rightIcon,
                rightIconTint: .systemRed
            )
        case let .playlist(title, _):
            navigationBar.configure(
                title: title,
                leftIcon: leftIcon,
                leftIconTint: .mainLabelColor,
                rightIcon: rightIcon, // rightIcon이 없으면 버튼이 표시 x
                rightIconTint: .systemRed
            )
        default:
            break
        }

        navigationBar.delegate = self
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

#warning("김건우 -> 각 셀을 클릭하면 동영상 출력되게 수정!!")
#warning("김건우 -> CompositionalLayout 임시값 수정하기")
    private func createCompositionalLayout() -> UICollectionViewCompositionalLayout {
        let sectionProvider: UICollectionViewCompositionalLayoutSectionProvider = { [weak self] sectionIndex, environment in

            let itemWidthDimension: NSCollectionLayoutDimension = environment.isHorizontalSizeClassCompact
            ? .fractionalWidth(1.0) : .fractionalWidth(0.33)
            let itemSize = NSCollectionLayoutSize(
                widthDimension: itemWidthDimension, // 임시 값
                heightDimension: .absolute(100) // 임시 값
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            let columnCount = environment.isHorizontalSizeClassCompact ? 1 : 3
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0), // 임시 값
                heightDimension: .absolute(100) // 임시 값
            )
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: groupSize,
                repeatingSubitem: item,
                count: columnCount
            )
            group.interItemSpacing = .flexible(8) // 임시 값

            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 8 // 임시 값

            if case .playback(_) = self?.videos {
                let headerSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .estimated(50)
                )
                let header = NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: headerSize,
                    elementKind: HeaderReusableView.id,
                    alignment: .topLeading
                )
                header.pinToVisibleBounds = true
                section.boundarySupplementaryItems = [header]
            }

            return section
        }

        return UICollectionViewCompositionalLayout(sectionProvider: sectionProvider)
    }
}

// MARK: - Setup DataSource

extension VideoListViewController {
#warning("김건우 -> 참조 사이클 문제 다시 확인해보기")
    private func setupDataSource() {

        let cellRagistration = createVideoCellRagistration()
        let headerRagistration = createHeaderRagistration()

        dataSource = PlaylistDiffableDataSource(collectionView: collectionView) { collectionView, indexPath, item in
            return collectionView.dequeueConfiguredReusableCell(
                using: cellRagistration,
                for: indexPath,
                item: item
            )
        }
        dataSource?.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
            guard case .playback(_) = self?.videos else { return .init() }

            return collectionView.dequeueConfiguredReusableSupplementary(
                using: headerRagistration,
                for: indexPath
            )
        }

        applySnapshot()
    }

    private func createVideoCellRagistration() -> UICollectionView.CellRegistration<MediumVideoCell, VideoList.Item> {
        UICollectionView.CellRegistration<MediumVideoCell, VideoList.Item>(cellNib: MediumVideoCell.nib) { cell, indexPath, item in
            var viewModel: MediumVideoViewModel
            switch item {
            case .playback(let entity):
                viewModel = MediumVideoViewModel(
                    tags: entity.tags,
                    userName: entity.user,
                    viewCount: Int(entity.views),
                    duration: Int(entity.duration),
                    thumbnailUrl: entity.video?.medium.thumbnail
                )
            case .playlist(let entity):
                viewModel = MediumVideoViewModel(
                    tags: entity.tags,
                    userName: entity.user,
                    viewCount: Int(entity.views),
                    duration: Int(entity.duration),
                    thumbnailUrl: entity.video?.medium.thumbnail
                )
            }
            cell.configure(viewModel)
            cell.delegate = self
            
            if case let .playlist(name, _) = self.videos,
               name == CoreDataString.bookmarkedPlaylistName {
                cell.isBookMark = true
            } else {
                cell.configureMenu(
                    deleteAction: { [weak self] in
                        guard let self = self else { return }
                        // 삭제 처리 코드
                        self.showDeleteAlert(
                            "재생 목록 전체 삭제",
                            message: "정말 전체 재생목록을 삭제하시겠습니까? 이 작업은 되돌릴 수 없습니다.",
                            onConfirm: { _ in

                            },
                            onCancel: { _ in
                            }
                        )
                    }
                )
            }
        }
    }

    private func createHeaderRagistration() -> UICollectionView.SupplementaryRegistration<HeaderReusableView> {
        UICollectionView.SupplementaryRegistration<HeaderReusableView>(supplementaryNib: HeaderReusableView.nib, elementKind: HeaderReusableView.id) { supplementaryView, elementKind, indexPath in
            guard let section = self.dataSource?.sectionIdentifier(for: indexPath.section),
            let createdAt = section.name else { return }
            supplementaryView.configure(title: createdAt)
        }
    }

    private func applySnapshot(query: String? = nil) {
        switch videos {
        case .playback(_):
            applyPlaybackSnapshot(query: query)
        default: // playlist
            applyPlaylistSnapshot(query: query)
        }
    }

    private func applyPlaylistSnapshot(query: String? = nil) {
        guard case let .playlist(name, _) = videos,
              let playback = self.playlistFetchedResultsController?.fetchedObjects?.first(where: { $0.name ==  name }),
              let entities = playback.playlistVideos?.allObjects as? [PlaylistVideoEntity]    else {
            return
        }


        let filteredEntities = entities.filter { entity in
            // 검색어가 nil이거나 비어있다면 필터링하지 않기 (전체 출력)
            guard let query = query, !query.isEmpty else { return true }
            let tags = entity.tags.split(by: ","), author = entity.user
            // 태그 중 하나라도 검색어와 일치하면 or 저자가 검색어와 일치하면
            return tags.some({ $0.localizedCaseInsensitiveContains(query) }) || author.localizedCaseInsensitiveContains(query)
        }

        let playlistItems: [VideoList.Item] = filteredEntities.map { VideoList.Item.playlist($0) }

        var snapshot = NSDiffableDataSourceSnapshot<VideoList.Section, VideoList.Item>()
        let playlistSection = VideoList.Section(type: .playlist)
        snapshot.appendSections([playlistSection])
        snapshot.appendItems(playlistItems, toSection: playlistSection)
        dataSource?.apply(snapshot, animatingDifferences: true)
        
        if entities.isEmpty {
            print("비어 있음!")
            return
        }

        if filteredEntities.isEmpty {
            print("검색 결과 비어 있음!")
            return
        }
    }

    private func applyPlaybackSnapshot(query: String? = nil) {
        guard case .playback = videos,
              let entities = self.playbackFetchedResultsController?.fetchedObjects else {
            return
        }

        let filteredEntities = entities.filter { entity in
            // 검색어가 nil이거나 비어있다면 필터링하지 않기 (전체 출력)
            guard let query = query, !query.isEmpty else { return true }
            let tags = entity.tags.split(by: ","), author = entity.user
            // 태그 중 하나라도 검색어와 일치하면 or 저자가 검색어와 일치하면
            return tags.some({ $0.localizedCaseInsensitiveContains(query) }) || author.localizedCaseInsensitiveContains(query)
        }

        let groupedEntities = Dictionary(grouping: filteredEntities) { entity in
            Calendar.current.startOfDay(for: entity.createdAt)
        }
        let descendingSortedEntities = groupedEntities.sorted { $0.key > $1.key }

        var snapshot = NSDiffableDataSourceSnapshot<VideoList.Section, VideoList.Item>()
        descendingSortedEntities.forEach { date, entities in
            let playbackItems = entities.map { VideoList.Item.playback($0) }
            let playbackSection = VideoList.Section(
                type: .playback,
                name: date.formatter(.yyyyMMdd)
            )

            snapshot.appendSections([playbackSection])
            snapshot.appendItems(playbackItems, toSection: playbackSection)
        }
        dataSource?.apply(snapshot, animatingDifferences: true)


        if entities.isEmpty {
            print("비어 있음!")
            return
        }

        if filteredEntities.isEmpty {
            print("검색 결과 비어 있음!")
            return
        }
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension VideoListViewController: NSFetchedResultsControllerDelegate {

    func controller(
        _ controller: NSFetchedResultsController<any NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?
    ) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.applySnapshot()
        }
    }
}


// MARK: - UICollectionViewDelegate

extension VideoListViewController: UICollectionViewDelegate {

    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
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


// MARK - UITextFieldDelegate

extension VideoListViewController: UITextFieldDelegate {

    func textFieldDidBeginEditing(_ textField: UITextField) {
        collectionView.scrollToTop()
        moveCloseButton(toRight: false)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let currentText = textField.text else { return true }
        if currentText.isEmpty {
            moveCloseButton(toRight: true)
        }
        searchBar.endEditing(true)
        return true
    }

    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        guard let currentText = textField.text,
              let textRange = Range(range, in: currentText) else {
            return false
        }

        let query = currentText.replacingCharacters(in: textRange, with: string)
        applySnapshot(query: query)
        collectionView.scrollToTop()
        return true
    }

    private func moveCloseButton(toRight bool: Bool) {
        closeButtonTrailingConstraint.constant = bool ? -50 : 0
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }
}


// MARK: - NavigationBarDelegate

extension VideoListViewController: NavigationBarDelegate {

    func navigationBarDidTapLeft(_ navBar: NavigationBar) {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - MediumVideoButtonDelegate

extension VideoListViewController: MediumVideoButtonDelegate {
    
    func deleteAction(_ collectionViewCell: UICollectionViewCell) {
        guard let indexPath = collectionView.indexPath(for: collectionViewCell),
              let item = dataSource?.itemIdentifier(for: indexPath) else {
            return
        }
        
        switch item {
        case .playlist(let playlistVideoEntity):
            CoreDataService.shared.delete(playlistVideoEntity)
        case .playback(let playbackHistoryEntity):
            CoreDataService.shared.delete(playbackHistoryEntity)
        }
    }
}


//
//  VideoListViewController.swift
//  Media
//
//  Created by 김건우 on 6/9/25.
//

import UIKit

/// 재생 기록 또는 재생 목록에 따라 표시할 비디오 목록의 유형을 나타내는 열거형입니다.
enum VideoListType {
    /// 재생 기록에 기반한 비디오 목록
    case playback([PlaybackHistoryEntity])
    /// 재생 목록에 기반한 비디오 목록
    case playlist([PlaylistVideoEntity])
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
    
    // MARK: - Lifecycles
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupDataSource()
        
        collectionView.collectionViewLayout = createCompositionalLayout()
    }
    
    @IBAction func didTapCloseButton(_ sender: Any) {
        searchBar.text = nil
        searchBar.endEditing(true)
        moveCloseButton(toRight: true)
    }

    override func setupAttributes() {
        super.setupAttributes()

        setupNavigationBar()
#warning("김건우 -> 검색 바 플레이스 홀더 바꾸기")
        searchBar.apply {
            $0.delegate = self
            $0.placeholder = "title, author, "
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
                title: "Playback",
                leftIcon: leftIcon,
                leftIconTint: .mainLabelColor,
                rightIcon: rightIcon,
                rightIconTint: .systemRed
            )
        default: // playlist
            navigationBar.configure(
                title: "Playback",
                leftIcon: leftIcon,
                leftIconTint: .mainLabelColor,
                rightIcon: rightIcon, // rightIcon이 없으면 버튼이 표시 x
                rightIconTint: .systemRed
            )
        }

        navigationBar.delegate = self
    }

#warning("김건우 -> CompositionalLayout 임시값 수정하기")
    private func createCompositionalLayout() -> UICollectionViewCompositionalLayout {
        let sectionProvider: UICollectionViewCompositionalLayoutSectionProvider = { [weak self] sectionIndex, environment in

            let itemWidthDimension: NSCollectionLayoutDimension = environment.isHorizontalSizeClassCompact
            ? .fractionalWidth(1.0) : .fractionalWidth(0.33)
            let itemSize = NSCollectionLayoutSize(
                widthDimension: itemWidthDimension, // 임시 값
                heightDimension: .estimated(200) // 임시 값
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            let columnCount = environment.isHorizontalSizeClassCompact ? 1 : 3
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

            if case .playback(_) = self?.videos {
                let headerSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .estimated(50)
                )
                let header = NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: headerSize,
                    elementKind: ColorCollectiorReusableView.id,
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
    
    #warning("김건우 -> 데이터 소스를 '진짜 셀'로 교체하기 + 임시 셀 삭제")
#warning("김건우 -> Ragistration 관련 코도 리팩토링하기 ")
    private func setupDataSource() {
        // 임시 셀 등록
        let cellRagistration = UICollectionView.CellRegistration<HistoryCollectionViewCell, VideoList.Item> { cell, indexPath, item in
            cell.backgroundColor = UIColor.random
        }

        // 임시 헤더 등록
        let headerRagistration = UICollectionView.SupplementaryRegistration<ColorCollectiorReusableView>(elementKind: ColorCollectiorReusableView.id) { supplementaryView, elementKind, indexPath in
            guard let section = self.dataSource?.sectionIdentifier(for: indexPath.section),
            let createdAt = section.name else { return }
            supplementaryView.label.text = "\(createdAt)"
            supplementaryView.backgroundColor = UIColor.random
        }

        // 임시 데이터 소스 코드
        dataSource = PlaylistDiffableDataSource(collectionView: collectionView) { collectionView, indexPath, item in
            return collectionView.dequeueConfiguredReusableCell(
                using: cellRagistration,
                for: indexPath,
                item: item
            )
        }

        // 임시 데이터 소스 코드
        dataSource?.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
            guard case .playback(_) = self?.videos else { return .init() }

            return collectionView.dequeueConfiguredReusableSupplementary(
                using: headerRagistration,
                for: indexPath
            )
        }

        applySnapshot()
    }
    
    private func applySnapshot() {
        switch videos {
        case .playback(_):
            applyPlaybackSnapshot()
        default: // playlist
            applyPlaylistSnapshot()
        }
    }

    #warning("김건우 -> 검색어 쿼리 관련 스냅샷 코드 작성 + 코드 리팩토링")
    private func applyPlaylistSnapshot() {
        guard case let .playlist(entities) = videos else { return }
        let playlistItems: [VideoList.Item] = entities.map { VideoList.Item.playlist($0) }

        var snapshot = NSDiffableDataSourceSnapshot<VideoList.Section, VideoList.Item>()
        let playlistSection = VideoList.Section(type: .playlist)
        snapshot.appendSections([playlistSection])
        snapshot.appendItems(playlistItems, toSection: playlistSection)
        dataSource?.apply(snapshot, animatingDifferences: true)
    }

    private func applyPlaybackSnapshot() {
        guard case let .playback(entities) = videos else { return }
        let groupedEntities = Dictionary(grouping: entities) { entity in
            Calendar.current.startOfDay(for: entity.createdAt ?? .now)
        }
        let descendingGroupedEntities = groupedEntities.sorted { $0.key > $1.key }

        var snapshot = NSDiffableDataSourceSnapshot<VideoList.Section, VideoList.Item>()
        descendingGroupedEntities.forEach { date, entities in
            let playbackItems = entities.map { VideoList.Item.playback($0) }
            let playbackSection = VideoList.Section(
                type: .playback,
                name: date.formatter(.yyyyMMdd)
            )

            snapshot.appendSections([playbackSection])
            snapshot.appendItems(playbackItems, toSection: playbackSection)
        }
        dataSource?.apply(snapshot, animatingDifferences: true)
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

        let updatedText = currentText.replacingCharacters(in: textRange, with: string)
        #warning("김건우 -> 재생 목록 및 시청 기록에서 검색 연산 구현")

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

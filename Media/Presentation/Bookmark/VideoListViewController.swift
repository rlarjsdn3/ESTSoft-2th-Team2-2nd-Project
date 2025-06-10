//
//  VideoListViewController.swift
//  Media
//
//  Created by 김건우 on 6/9/25.
//

import UIKit

enum VideoListType {
    case playback([PlaybackHistoryEntity])
    case playlist([PlaylistVideoEntity])
}

final class VideoListViewController: StoryboardViewController {

    enum Metric {
        static let collectionViewTopInset: CGFloat = 56
    }

    typealias PlaylistDiffableDataSource = UICollectionViewDiffableDataSource<VideoList.Section, VideoList.Item>

    var videos: VideoListType?
    private let coreDataService = CoreDataService.shared

    private var dataSource: PlaylistDiffableDataSource? = nil

    ///
    private var shouldAnimateSearchBarByScrolling = true

    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var navigationBar: NavigationBar!
    @IBOutlet weak var collectionView: UICollectionView!

    @IBOutlet weak var searchContainer: UIView!
    @IBOutlet weak var searchBar: UITextField!


    @IBOutlet weak var searchContainerTopToSafeAreaConstraint: NSLayoutConstraint!
    @IBOutlet weak var searchContainerTopToNavigationBarConstraint: NSLayoutConstraint!

    @IBOutlet weak var searchContainerLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var searchContainerTrailingConstraint: NSLayoutConstraint!



    override func viewDidLoad() {
        super.viewDidLoad()

        setupDataSource()
    }
    
    @IBAction func didTapCloseButton(_ sender: Any) {
        searchBar.text = nil
        searchBar.endEditing(true)

        moveSearchContainer(toTop: false)
    }

    override func setupAttributes() {
        super.setupAttributes()

        setupNavigationBar()

        searchContainer.apply {
            $0.layer.cornerRadius = 14
            $0.layer.masksToBounds = true
        }

        searchBar.apply {
            $0.placeholder = "search qeury..."
            $0.delegate = self
        }

        collectionView.apply {
            $0.collectionViewLayout = createCompositionalLayout()
            $0.contentInset = UIEdgeInsets(
                top: Metric.collectionViewTopInset, left: 0,
                bottom: 0, right: 0
            )
        }

        closeButton.alpha = 0
    }

    private func setupNavigationBar() {
        let leftIcon = UIImage(systemName: "arrow.left")
        let rightIcon = UIImage(systemName: "trash.fill")
        switch videos {
        case .playback(_):
            navigationBar.configure(
                title: "Playback",
                leftIcon: leftIcon,
                leftIconTint: .mainLabelColor,
                rightIcon: rightIcon,
                rightIconTint: .systemRed
            )
        default: // playlist
            navigationBar.configure(
                title: "Playlist",
                leftIcon: leftIcon,
                leftIconTint: .mainLabelColor
            )
        }

        navigationBar.delegate = self
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

extension VideoListViewController {
    
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
        guard case let .playlist(entities) = videos else { return }
        let playlistItems: [VideoList.Item] = entities.map { VideoList.Item.playlist($0) }

        var snapshot = NSDiffableDataSourceSnapshot<VideoList.Section, VideoList.Item>()
        let playlistSection = VideoList.Section(type: .playlist)
        snapshot.appendSections([playlistSection])
        snapshot.appendItems(playlistItems, toSection: playlistSection)
        dataSource?.apply(snapshot, animatingDifferences: true)
    }
}


// MARK: - UICollectionViewDelegate

extension VideoListViewController: UICollectionViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentInset = scrollView.contentInset
        let contentOffset = scrollView.contentOffset
        let offsetY = contentOffset.y + contentInset.top

        if shouldAnimateSearchBarByScrolling {
            // 검색바 투명도 조절
            let alpha = 1 - offsetY / 12.5
            searchContainer.alpha = alpha < 0 ? 0 : alpha

            // 검색 바 스케일 조절
            let rawScale = 1 - offsetY / 200
            let scalingFactor = (1 * rawScale) >= 0.925 ? (1 * rawScale) : 0.925
            let clampedScale = scalingFactor >= 1 ? 1 : scalingFactor
            searchContainer.transform = CGAffineTransform(scaleX: clampedScale, y: clampedScale)

        }
    }

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


// MARK - UISeachBarDelegate

extension VideoListViewController: UITextFieldDelegate {

    func textFieldDidBeginEditing(_ textField: UITextField) {
        moveSearchContainer(toTop: true)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchBar.endEditing(true)
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

        return true
    }

    private func moveSearchContainer(toTop bool: Bool) {
        shouldAnimateSearchBarByScrolling = false

        searchContainerTopToSafeAreaConstraint.priority = bool ? .defaultHigh : .defaultLow
        searchContainerTopToNavigationBarConstraint.priority = bool ? .defaultLow : .defaultHigh
        searchContainerLeadingConstraint.constant = bool ? 48 : 8
        searchContainerTrailingConstraint.constant = bool ? 48 : 8

        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
            self.closeButton.alpha = bool ? 1 : 0
            self.collectionView.contentInset.top = bool ? 4 : Metric.collectionViewTopInset
            self.navigationBar.titleLabel.alpha = bool ? 0 : 1
        } completion: { _ in
            self.shouldAnimateSearchBarByScrolling = true
        }

        if !bool {
            let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
            self.collectionView.scrollRectToVisible(rect, animated: true)
        }

    }
}


// MARK: - NavigationBarDelegate

extension VideoListViewController: NavigationBarDelegate {

    func navigationBarDidTapLeft(_ navBar: NavigationBar) {
        navigationController?.popViewController(animated: true)
    }
}

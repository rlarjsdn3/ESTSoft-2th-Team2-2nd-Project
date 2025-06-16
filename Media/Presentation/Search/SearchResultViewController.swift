//
//  SearchResultViewController.swift
//  Media
//
//  Created by 백현진 on 6/9/25.
//

import AVKit
import UIKit

final class SearchResultViewController: StoryboardViewController {

    @IBOutlet weak var navigationBar: NavigationBar!
    @IBOutlet weak var videoCollectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var noVideoFoundImageView: UIImageView!

    private lazy var refreshControl = UIRefreshControl()

    var keyword: String?

    private var records: [SearchRecordEntity] = []
    var recordManager = SearchRecordManager()

    private let dataService: DataTransferService = DefaultDataTransferService()
    private let videoService: VideoPlayerService = DefaultVideoPlayerService()
    private let userDefaults = UserDefaultsService.shared

    private var selectedCategories: Category? = {
        let raw: String? = UserDefaultsService.shared[keyPath: \.filterCategories]

        return raw.flatMap { Category(rawValue: $0) }
    }()

    private var selectedOrder: Order? = {
        let raw: String? = UserDefaultsService.shared[keyPath: \.filterOrders]

        return raw.flatMap { Order(rawValue: $0) }
    }()

    private var selectedDuration: Duration? = {
        let raw: String? = UserDefaultsService.shared[keyPath: \.filterDurations]

        return raw.flatMap { descript in
            Duration.allCases.first { $0.description == descript }
        }
    }()

    var observation: NSKeyValueObservation?

    private let videoDataService = VideoDataService.shared

    // 페이지네이션 프로퍼티
    private var hits: [PixabayResponse.Hit] = []
    private var currentPage = 1
    private let perPage = 20 // 한 페이지당 영상 개수
    private var totalHits = 0 // 전체 결과 수
    private var isLoading = false
    private var totalPages: Int { // 전체 페이지 수 계산 프로퍼티
        let pages = Double(totalHits) / Double(perPage)
        return Int(ceil(pages))
    }

    /// 필터 갯수 표현 라벨입니다.
    private lazy var filterLabel: UILabel = {
        let	label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .systemRed
        label.textColor = .white
        label.font = .systemFont(ofSize: 10, weight: .bold)
        label.textAlignment = .center
        label.layer.masksToBounds = true
        label.isHidden = true
        return label
    }()

    private var recentSearchHeightConstraint: NSLayoutConstraint!

    /// 서치 결과 뷰에서 서치를 시작할 때 나오는 생략된 서치 뷰
    private lazy var recentSearchContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.background

        view.layer.shadowColor = UIColor.label.cgColor
        view.layer.shadowOpacity = 0.2
        view.layer.shadowRadius = 2
        view.layer.shadowOffset = .init(width: 0, height: 4)
        view.clipsToBounds = false

        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(
            UINib(nibName: SearchTableViewCell.id, bundle: nil),
            forCellReuseIdentifier: SearchTableViewCell.id)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        view.isHidden = true

        return view
    }()

    deinit {
        print("resultVC 메모리 해제")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        fetchVideos(page: 1, category: selectedCategories, order: selectedOrder, duration: selectedDuration)
        setKeyBoardDismissGesture()
    }

    override func setupHierachy() {
        configureSearchBar()
        configureCollectionView()
        configureRefreshControl()
        videoCollectionView.isHidden = true
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()

        NSLayoutConstraint.activate([
            filterLabel.trailingAnchor.constraint(equalTo: navigationBar.rightButton.trailingAnchor, constant: 5),
            filterLabel.topAnchor.constraint(equalTo: navigationBar.rightButton.topAnchor, constant: -10),
            filterLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 15),
            filterLabel.heightAnchor.constraint(equalToConstant: 15)
        ])

        setupRecentSearchView()
    }

    override func setupAttributes() {
        self.view.backgroundColor = UIColor.background
        self.videoCollectionView.backgroundColor = .clear
        changeStateOfFilterButton()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        filterLabel.layer.cornerRadius = filterLabel.frame.size.height / 2
    }

    // 화면 회전
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: nil) { [weak self] _ in
            guard let self = self else { return }

            //VC 계층에 떠있는 AlertController dismiss
            if let alert = self.presentedViewController as? UIAlertController {
                alert.dismiss(animated: true) {
                    print("alert 닫힘-----------------------")
                }
            }
            self.videoCollectionView.reloadData()
        }
    }

    // 키보드 내리기
    @objc private func dismissKeyboard() {
        view.endEditing(true)
        hideRecentSearches()
    }

    // 서치 컨테이너 뷰
    private func setupRecentSearchView() {
        // 검색바 바로 아래에 붙이기
        guard let nb = navigationBar.superview else { return }
        recentSearchContainerView.translatesAutoresizingMaskIntoConstraints = false
        nb.addSubview(recentSearchContainerView)

        recentSearchHeightConstraint = recentSearchContainerView.heightAnchor.constraint(equalToConstant: 0)

        NSLayoutConstraint.activate([
            recentSearchContainerView.topAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: 4),
            recentSearchContainerView.leadingAnchor.constraint(equalTo: nb.leadingAnchor),
            recentSearchContainerView.trailingAnchor.constraint(equalTo: nb.trailingAnchor),
            recentSearchHeightConstraint //동적 높이 조절 constraint
        ])
    }

    // 네비게이션 바 기본 설정
    private func configureSearchBar() {
        self.navigationController?.isNavigationBarHidden = true
        navigationBar.searchBar.delegate = self
        navigationBar.searchBar.returnKeyType = .search
        navigationBar.searchBar.searchTextField.enablesReturnKeyAutomatically = true
        navigationBar.delegate = self
        navigationBar.configure(
            title: keyword ?? "",
            leftIcon: UIImage(systemName: "arrow.left"),
            rightIcon: UIImage(systemName: "slider.horizontal.3"),
            isSearchMode: true
        )
        navigationBar.rightButton.addSubview(filterLabel)
        navigationBar.searchBar.text = keyword
    }


    // 키보드 dismiss
    private func setKeyBoardDismissGesture() {
        let tap = UITapGestureRecognizer(
            target: self,
            action: #selector(dismissKeyboard)
        )
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    // 최근 서치 기록 띄어줌
    private func showRecentSearches() {
        loadRecentSearches()
        recentSearchContainerView.isHidden = false
    }

    // 서치 기록 5개 가져오기
    private func loadRecentSearches() {
        records = (try? recordManager.fetchRecent(limit: 5)) ?? []

        let cellHeight: CGFloat = 40
        let count = CGFloat(records.count)

        recentSearchHeightConstraint.constant = count * cellHeight
        (recentSearchContainerView.subviews.compactMap { $0 as? UITableView }).first?.reloadData()
    }

    // 최근 서치 기록 없애기
    private func hideRecentSearches() {
        recentSearchContainerView.isHidden = true
    }

    // 재훈님 collectionView 등록
    private func configureCollectionView() {
        videoCollectionView.register(
            UINib(nibName: "VideoCell", bundle: nil),
            forCellWithReuseIdentifier: VideoCell.id
        )
        videoCollectionView.dataSource = self
        videoCollectionView.delegate = self
    }

    // 실시간 필터 색 반영하기 위한 userDefault 리로드
    func reloadSavedFilters() {
        // 1) 카테고리
        if let rawCat: String = userDefaults[keyPath: \.filterCategories],
           let cat = Category(rawValue: rawCat) {
            selectedCategories = cat
        } else {
            selectedCategories = nil
        }

        // 2) 정렬
        if let rawOrd: String = userDefaults[keyPath: \.filterOrders],
           let ord = Order(rawValue: rawOrd) {
            selectedOrder = ord
        } else {
            selectedOrder = nil
        }

        // 3) 길이
        if let rawDur: String = userDefaults[keyPath: \.filterDurations],
           let dur = Duration.allCases.first(where: { $0.description == rawDur }) {
            selectedDuration = dur
        } else {
            selectedDuration = nil
        }
    }

    // 필터가 하나라도 켜져 있으면 filterButton색, filterLabel 활성화
    private func changeStateOfFilterButton() {
        let count = (selectedCategories != nil ? 1 : 0) + (selectedOrder != nil ? 1 : 0) + (selectedDuration != nil ? 1 : 0)
        if count > 0 {
            navigationBar.rightButton.tintColor = .red
            filterLabel.isHidden = false
            filterLabel.text = "\(count)"
        } else {
            filterLabel.isHidden = true
            navigationBar.rightButton.tintColor = .label
        }
    }

    func showSheet() {
        let storyboard = UIStoryboard(name: "SearchFilterViewController", bundle: nil)
        let vc = storyboard.instantiateViewController(
            identifier: "SearchFilterViewController"
        ) as! SearchFilterViewController

        vc.onApply = {
            Toast.makeToast("Filter has been applied.", systemName: "slider.horizontal.3").present()
            self.reloadSavedFilters()
            self.changeStateOfFilterButton()
        }

        vc.modalPresentationStyle = .pageSheet

        if let sheet = vc.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.selectedDetentIdentifier = .medium

            // 디밍: modal이 medium/large 상관 없이 반투명 처리
            sheet.largestUndimmedDetentIdentifier = nil
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            sheet.prefersEdgeAttachedInCompactHeight = true
            sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 20
            sheet.delegate = vc
        }

        present(vc, animated: true)
    }

    private func configureRefreshControl() {
        refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        videoCollectionView.refreshControl = refreshControl
    }

    @objc private func didPullToRefresh() {
        if isLoading {
            refreshControl.endRefreshing()
            return
        }

        refreshControl.beginRefreshing()
        fetchVideos(page: 1, category: selectedCategories, order: selectedOrder, duration: selectedDuration)
    }

    private func endRefreshing() {
        if refreshControl.isRefreshing {
            refreshControl.endRefreshing()
        }
    }

    // MARK: – 데이터 Fetch
    private func fetchVideos(
        page: Int,
        category: Category? = nil,
        order: Order? = nil,
        duration: Duration? = nil
    ) {
        guard !isLoading else { return }
        isLoading = true

        if page == 1 {
            DispatchQueue.main.async {
                self.hits.removeAll()
                self.videoCollectionView.reloadData()
            }
        }

        currentPage = page

        let endpoint = APIEndpoints.pixabay(
            query: keyword,
            category: category,
            order: order ?? .popular,
            page: page,
            perPage: perPage
        )

        dataService.request(endpoint) { [weak self] result in
            guard let self = self else { return }
            self.isLoading = false

            switch result {
            case .success(let response):
                DispatchQueue.main.async {
                    self.totalHits = response.totalHits

                    // page==1 이면 새 배열로 교체, 아니면 append
                    if page == 1 {
                        self.hits = response.hits
                    } else {
                        self.hits.append(contentsOf: response.hits)
                    }


                    if let dur = duration {
                        self.hits = self.hits.filter {
                            Duration(seconds: $0.duration) == dur
                        }
                    }

                    self.activityIndicator.stopAnimating()
                    self.endRefreshing()
                    self.noVideoFoundImageView.isHidden = !self.hits.isEmpty
                    self.videoCollectionView.isHidden = false

                    UIView.transition(with: self.videoCollectionView, duration: 0.3) {
                        self.videoCollectionView.reloadData()
                    } completion: { _ in
                        if page == 1, self.hits.count > 0 {
                            self.videoCollectionView.setContentOffset(.zero, animated: false)
                        }
                    }
                }

            case .failure(let error):
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.endRefreshing()
                    self.showAlert(title: "Error",
                                   message: "There was a problem loading the video.",
                                   onPrimary: { _ in }
                    )
                }
            }
        }
    }

    // MARK: – 새 재생목록 Alert
    func showAddPlaylistAlert() {
        showTextFieldAlert(
            "Add New Playlist",message: "Enter a name for the new playlist.") { (action, newText) in
                if !PlaylistEntity.isExist(newText) {
                    let newPlaylist = PlaylistEntity(
                        name: newText,
                        insertInto: CoreDataService.shared.viewContext
                    )
                    CoreDataService.shared.insert(newPlaylist)
                    Toast.makeToast("'\(newPlaylist.name)' has been created", systemName: "list.clipboard").present()

                } else {
                    Toast.makeToast("A playlist with this name already exists").present()
                }
            } onCancel: { action in

            }
    }
}

extension SearchResultViewController: UICollectionViewDataSource {

    func formatDuration(seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return hits.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: VideoCell.id, for: indexPath) as! VideoCell

        let video = hits[indexPath.item]

        let viewModel = VideoCellViewModel(
            title: video.user,
            viewCount: video.views,
            duration: video.duration,
            thumbnailURL: video.videos.medium.thumbnail,
            profileImageURL: video.userImageUrl,
            likeCount: video.likes,
            tags: video.tags
        )

        cell.configure(with: viewModel)

        // 썸네일 터치시 영상 재생
        cell.onThumbnailTap = { [weak self] in
            guard let self = self else { return }
            self.videoService.playVideo(self, with: video) { error in
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
            self.videoDataService.addToWatchHistory(video)
        }

        // Ellipsis 버튼 실행
        cell.configureMenu(
            bookmarkAction: { [weak self] in
                guard let self = self else { return }

                // 북마크 추가 결과 처리
                switch self.videoDataService.addToBookmark(video) {
                case .success:
                    Toast.makeToast("Add to Bookmarks", systemName: "bookmark")
                        .present()
                case .failure(let err):
                    Toast.makeToast(err.localizedDescription, systemName: "bookmark.fill")
                        .present()
                }
            },
            playlistAction: { [weak self] in
                guard let self = self else { return }

                // 1) 존재하는 커스텀 재생목록 목록 불러오기
                let lists = self.videoDataService.playlists()

                // 2) 액션시트로 사용자에게 선택지 제시
                let alert = UIAlertController(title: "Select Playlist", message: nil, preferredStyle: .actionSheet)
                lists.forEach { pl in
                    alert.addAction(.init(title: pl.name, style: .default) { _ in
                        // 선택된 목록에 비디오 추가
                        self.videoDataService.add(video, toPlaylistNamed: pl.name)
                        Toast.makeToast("\"\(pl.name)\" added to playlist", systemName: "list.clipboard")
                            .present()
                    })
                }
                // 새 재생목록 만들기
                alert.addAction(.init(title: "Create New Playlist", style: .default) { _ in
                    self.showAddPlaylistAlert()
                })
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

                cell.layoutIfNeeded()

                if let pop = alert.popoverPresentationController {
                    pop.sourceView = cell.ellipsisButton
                    pop.sourceRect = cell.ellipsisButton.bounds
                    pop.permittedArrowDirections = [.any]
                }

                self.present(alert, animated: true)

            }
        )

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        // 마지막 몇 개 앞일 때만 트리거
        let thresholdIndex = hits.count - 5

        // 요청 할 페이지가 남아있어야 페이지네이션 진행
        guard currentPage < totalPages else { return }

        guard hits.count > 5 else { return }

        if indexPath.item >= thresholdIndex {
            fetchVideos(
                page: currentPage + 1,
                category: selectedCategories,
                order: selectedOrder,
                duration: selectedDuration
            )
        }
    }
}

extension SearchResultViewController: UICollectionViewDelegate, UIScrollViewDelegate {
    // 스크롤 시작 시 호출 메서드
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        view.endEditing(true)
        hideRecentSearches()
    }
}

extension SearchResultViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        // ipad대응
        let isPad = UIDevice.current.userInterfaceIdiom == .pad
        let interfaceOrientation: UIInterfaceOrientation
        interfaceOrientation = collectionView.window?.windowScene?.interfaceOrientation ?? .portrait
        let isLandscape = interfaceOrientation.isLandscape

        //iphone: 항상 1개
        //ipad: 세로 모드 2개, 가로모드 3개
        let itemsPerRow: CGFloat = {
            if isPad {
                return isLandscape ? 3 : 2
            } else {
                return 1
            }
        }()

        let spacing: CGFloat = 8
        let sideInset: CGFloat = 8
        let totalSpacing = spacing * (itemsPerRow - 1) + sideInset * 2

        let availableWidth = collectionView.bounds.width - totalSpacing
        let cellWidth = availableWidth / itemsPerRow
        let cellHeight = cellWidth * 9 / 16 + 80

        return CGSize(width: cellWidth, height: cellHeight)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return .init(top: 8, left: 8, bottom: 0, right: 8)
    }
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }

    func collectionView(_ cv: UICollectionView,
                        layout cvl: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
}

extension SearchResultViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let keyword = searchBar.text, !keyword.isEmpty else { return }

        let trimmed = keyword.trimmingCharacters(in: .whitespacesAndNewlines)

        // 키보드 내리기
        searchBar.resignFirstResponder()

        // 서치 뷰 내리기
        hideRecentSearches()

        //검색 기록 저장
        do {
            try recordManager.save(query: trimmed)
        } catch {
            print(error)
        }
        loadRecentSearches()

        self.keyword = trimmed
        self.activityIndicator.startAnimating()
        self.videoCollectionView.isHidden = true

        fetchVideos(
            page: 1,
            category: selectedCategories,
            order: selectedOrder,
            duration: selectedDuration
        )
    }

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        showRecentSearches()
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        hideRecentSearches()
    }
}

extension SearchResultViewController: NavigationBarDelegate {
    //naviationBar event
    func navigationBarDidTapLeft(_ navBar: NavigationBar) {
        self.navigationController?.popViewController(animated: true)
    }

    func navigationBarDidTapRight(_ navBar: NavigationBar) {
        showSheet()
    }
}

extension SearchResultViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return records.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SearchTableViewCell.id, for: indexPath) as! SearchTableViewCell
        let target = records[indexPath.row]
        cell.searchLabel.text = target.query

        return cell
    }
}

extension SearchResultViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let target = records[indexPath.row].query
        navigationBar.searchBar.text = target
        hideRecentSearches()
        navigationBar.searchBar.resignFirstResponder()

        searchBarSearchButtonClicked(navigationBar.searchBar)
    }

}

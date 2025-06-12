//
//  SearchResultViewController.swift
//  Media
//
//  Created by 백현진 on 6/9/25.
//

import UIKit

final class SearchResultViewController: StoryboardViewController {
    @IBOutlet weak var navigationBar: NavigationBar!
    @IBOutlet weak var videoCollectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var noVideoFoundImageView: UIImageView!

    private lazy var refreshControl = UIRefreshControl()
    var keyword: String?

    private let dataService: DataTransferService = DefaultDataTransferService()
    private let userDefaults = UserDefaultsService.shared

    private var selectedCategories: Category? = {
        let raw: String? = UserDefaultsService.shared[keyPath: \.filterCategories]

        return raw.flatMap { Category(rawValue: $0) }
    }()

    private var selectedOrder: Order? = {
        let raw: String? = UserDefaultsService.shared[keyPath: \.filterOrders]

        return raw.flatMap { Order(rawValue: $0) }
    }()

    private lazy var selectedDuration: Duration? = {
        let raw: String? = UserDefaultsService.shared[keyPath: \.filterDurations]

        return raw.flatMap { descript in
            Duration.allCases.first { $0.description == descript }
        }
    }()

    //페이지네이션 프로퍼티
    private var hits: [PixabayResponse.Hit] = []
    private var currentPage = 1
    private let perPage = 20 // 한 페이지당 영상 개수
    private var totalHits = 0 // 전체 결과 수
    private var isLoading = false
    private var totalPages: Int { // 전체 페이지 수 계산 프로퍼티
        let pages = Double(totalHits) / Double(perPage)
        return Int(ceil(pages))
    }

    deinit {
        print("resultVC 메모리 해제")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        print(selectedCategories, selectedOrder, selectedDuration)
        videoCollectionView.isHidden = true
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        fetchVideos(page: 1, category: selectedCategories, order: selectedOrder, duration: selectedDuration)
    }

    override func setupHierachy() {
        configureSearchBar()
        configureCollectionView()
        configureRefreshControl()
    }

    override func setupAttributes() {
        self.view.backgroundColor = UIColor.background
        self.videoCollectionView.backgroundColor = .clear
        changeStateOfFilterButton()
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
        navigationBar.searchBar.text = keyword
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

    // 필터가 하나라도 켜져 있으면 filterButton 색변경
    private func changeStateOfFilterButton() {
        if selectedCategories != nil || selectedOrder != nil || selectedDuration != nil {
            navigationBar.rightButton.tintColor = .red
        } else {
            navigationBar.rightButton.tintColor = .label
        }
    }

    func showSheet() {
        let storyboard = UIStoryboard(name: "SearchFilterViewController", bundle: nil)
        let vc = storyboard.instantiateViewController(
            identifier: "SearchFilterViewController"
        ) as! SearchFilterViewController

        vc.onApply = {
            Toast.makeToast("필터가 적용되었습니다.", systemName: "slider.horizontal.3").present()
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
            hits.removeAll()
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
                self.totalHits = response.totalHits

                self.hits.append(contentsOf: response.hits)

                if let dur = duration {
                    self.hits = self.hits.filter {
                        Duration(seconds: $0.duration) == dur
                    }
                }

                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.endRefreshing()

                    if self.hits.isEmpty {
                        self.noVideoFoundImageView.isHidden = false
                    } else {
                        self.videoCollectionView.backgroundView = nil
                    }

                    self.videoCollectionView.isHidden = false
                    self.videoCollectionView.reloadData()
                }

            case .failure(let error):
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.endRefreshing()
                    self.showAlert("오류", message: "영상을 불러오는 중 문제가 발생했습니다.") { _ in
                        print("확인", error)
                    } onCancel: { _ in
                        print("취소", error)
                    }
                }
            }
        }
    }
}

extension SearchResultViewController: UICollectionViewDataSource {

    func formatDuration(seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }

    // 조회 수 포맷
    func formatViewCount(_ count: Int) -> String {
        if count >= 10_000 {
            let value = Double(count) / 10_000
            // 소수점 검사이후 Int or Double
            if abs(value.rounded() - value) < 0.01 {
                return "\(Int(value))만 회"
            } else {
                return String(format: "%.1f만 회", value)
            }
        } else if count >= 1_000 {
            let value = Double(count) / 1_000
            if abs(value.rounded() - value) < 0.01 {
                return "\(Int(value))천 회"
            } else {
                return String(format: "%.1f천 회", value)
            }
        } else {
            return "\(count)회"
        }
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

extension SearchResultViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let width = videoCollectionView.bounds.width
        let height = width * 9 / 16 + 80
        return CGSize(width: width, height: height)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }

}

extension SearchResultViewController: UICollectionViewDelegate {

}


extension SearchResultViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let keyword = searchBar.text, !keyword.isEmpty else { return }

        // 키보드 내리기
        searchBar.resignFirstResponder()

        self.keyword = keyword
        self.activityIndicator.startAnimating()
        self.videoCollectionView.isHidden = true

        fetchVideos(
            page: 1,
            category: selectedCategories,
            order: selectedOrder,
            duration: selectedDuration
        )
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

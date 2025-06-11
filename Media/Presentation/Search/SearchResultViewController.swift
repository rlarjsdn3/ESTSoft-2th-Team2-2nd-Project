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
    private lazy var refreshControl = UIRefreshControl()

    var keyword: String?

    var getCategories: Category?
    var getOrder: Order?
    var getDuration: Duration?

    private var hits: [PixabayResponse.Hit] = []
    private let dataService: DataTransferService = DefaultDataTransferService()

    deinit {
        print("resultVC 메모리 해제")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        videoCollectionView.isHidden = true
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        fetchVideos(category: getCategories, order: getOrder, duration: getDuration)
    }

    override func setupHierachy() {
        configureSearchBar()
        configureCollectionView()
        configureRefreshControl()
    }

    override func setupAttributes() {
        self.view.backgroundColor = UIColor.background
        self.videoCollectionView.backgroundColor = .clear
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

    func showSheet() {
        let storyboard = UIStoryboard(name: "SearchFilterViewController", bundle: nil)
        let vc = storyboard.instantiateViewController(
            identifier: "SearchFilterViewController"
        ) as! SearchFilterViewController

        // 콜백
        vc.onApply = { [weak self] categories, order, duration in
            guard let self = self else { return }
            self.getCategories = categories.first
            self.getOrder = order.first
            self.getDuration = duration.first

            vc.dismiss(animated: true) {
                self.activityIndicator.startAnimating()
                self.videoCollectionView.isHidden = true
                self.fetchVideos(category: self.getCategories, order: self.getOrder, duration: self.getDuration)
            }
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
        fetchVideos(category: self.getCategories, order: self.getOrder, duration: self.getDuration)
    }

    private func endRefreshing() {
        if refreshControl.isRefreshing {
            refreshControl.endRefreshing()
        }
    }

    // MARK: – 데이터 Fetch
    private func fetchVideos(
        category: Category? = nil,
        order: Order?,
        duration: Duration? = nil
    ) {
        
        let endpoint = APIEndpoints.pixabay(
            query: keyword,
            category: category,
            order: order ?? .popular,
            page: 1,
            perPage: 20
        )



        dataService.request(endpoint) { [weak self] (result: Result<PixabayResponse, DataTransferError>) in
            guard let self = self else { return }

            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                self.endRefreshing()
                self.videoCollectionView.isHidden = false
            }

            switch result {
            case .success(let response):
                self.hits = response.hits

                // duration필터 조건이 nil이 아닐 때
//                if let durationFilter = duration {
//                    self.hits = self.hits.filter { hit in
//                        let last = Duration(seconds: hit.duration)
//                        return last ==  durationFilter
//                    }
//                }

                DispatchQueue.main.async {
                    self.videoCollectionView.reloadData()
                }

            case .failure(let error):
                if case let .networkFailiure(error) = error {
                        print("네트워크 오류:", error)
                } else if case let .parsing(error) = error {
                        print("디코딩 오류:", error)
                    } else {
                        print("기타 오류:", error)
                    }
//                DispatchQueue.main.async {
//                    self.showAlert("오류", message: "영상을 불러오는 중 문제가 발생했습니다.") { _ in
//                        print("확인", error)
//                    } onCancel: { _ in
//                        print("취소", error)
//                    }
//                }
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
            viewCountText: formatViewCount(video.views),
            durationText: formatDuration(seconds: video.duration),
            thumbnailURL: video.videos.medium.thumbnail,
            profileImageURL: video.userImageUrl,
            likeCountText: formatViewCount(video.likes),
            tags: video.tags
        )

        cell.configure(with: viewModel)
        return cell
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

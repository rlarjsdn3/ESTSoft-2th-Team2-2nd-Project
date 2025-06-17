
import UIKit
import AVKit
import AVFoundation
import CoreData

final class HomeViewController: StoryboardViewController, NavigationBarDelegate {
    private var selectedVideoURL: URL?

    var observation: NSKeyValueObservation?

    private let videoPlayerService: VideoPlayerService = DefaultVideoPlayerService()

    @IBOutlet weak var navigationBar: NavigationBar!

    @IBOutlet weak var categoryCollectionView: UICollectionView!

    @IBOutlet weak var contentUnavailableView: ContentUnavailableView!
    // 초기값설정
    var selectedCategoryIndex: Int = 0

    var selectedCategories: [String] = []

    @IBOutlet weak var videoCollectionView: UICollectionView!

    let service = DefaultDataTransferService()

    // 네비게이션 서치뷰로
    func navigationBarDidTapRight(_ navigationBar: NavigationBar) {
        let storyboard = UIStoryboard(name: "SearchViewController", bundle: nil)
        if let searchVC = storyboard.instantiateViewController(withIdentifier: "SearchViewController") as? SearchViewController {
            navigationController?.pushViewController(searchVC, animated: true)
        }
    }

    private var isTabBarConfigured = false
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if !isTabBarConfigured, let tabBar = self.tabBarController {
            TabBarConfigurator.configure(tabBarController: tabBar)
            isTabBarConfigured = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationBar.delegate = self

        navigationBar.configure(
            title: "Home",
            subtitle: "",
            rightIcon: UIImage(systemName: "magnifyingglass"),
            isSearchMode: false
        )

        NotificationCenter.default.addObserver(forName: .didSelectedCategories, object: nil, queue: .main) { [weak self]_ in
            guard let self = self else { return }
            let categories = TagsDataManager.shared.fetchSelectedCategories()
            self.selectedCategories = categories.map { $0.rawValue }
            self.categoryCollectionView.reloadData()
            self.fetchVideo(page: 1, isRepresh: true)
        }

        //AVAudioSession 설정
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("AVAudioSession 설정 실패: \(error)")
        }
        // CollectionView 델리게이트 & 데이터 소스
        videoCollectionView.contentInsetAdjustmentBehavior = .never

        categoryCollectionView.delegate = self
        categoryCollectionView.dataSource = self
        categoryCollectionView.register(UINib(nibName: "CategoryCell", bundle: nil), forCellWithReuseIdentifier: "CategoryCell")

        categoryCollectionView.contentInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 4)

        videoCollectionView.delegate = self
        videoCollectionView.dataSource = self
        videoCollectionView.register(UINib(nibName: "VideoCell", bundle: nil), forCellWithReuseIdentifier: "VideoCell")

        videoCollectionView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 90, right: 0)

        //Pull to Refresh 기능
        let  refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        videoCollectionView.refreshControl = refreshControl

        // 레이아웃 고정
        if let layout = videoCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.estimatedItemSize = .zero
        }

        fetchVideo(page: 1, isRepresh: true)

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true


        let categories = TagsDataManager.shared.fetchSelectedCategories()
        self.selectedCategories = categories.map { $0.rawValue }

        categoryCollectionView.reloadData()

        // 시청기록 처리 등 기존 코드 유지

        if let video = selectedVideo {
            savePlaybackHistoryToCoredata(video: video)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("viewWillDisappear")
    }

    // MARK: - 카테고리
    // Pixabay API에서 받아온 비디오 데이터 배열
    private var videos: [PixabayResponse.Hit] = []

    // 카테고리 배열 순서
    var displayedCategories: [String] {

        return ["All"] + selectedCategories
    }

    // 필터링 소문자로 비교
    var selectedCategoryName: String? {
        if selectedCategoryIndex == 0 {
            return nil
        }
        return selectedCategories[selectedCategoryIndex - 1]
    }

    private var currentPage: Int = 1

    private var isFetching: Bool = false

    private var hasMoreData: Bool = true


    // 네트워크
    private func callPixabayAPI(
        query: String?,
        page: Int,
        perPage: Int,
        completion: @escaping (Result<PixabayResponse, Error>) -> Void) {

            let endpoint = APIEndpoints.pixabay(
                query: query,
                category: nil,
                order: .popular,
                page: page,
                perPage: perPage
            )

            service.request(endpoint) { [weak self] result in
                DispatchQueue.main.async {
                    guard let self = self else { return }

                    switch result {
                    case .success(let response):
                        completion(.success(response))
                        UIView.animate(withDuration: 0.25) {
                            self.contentUnavailableView.alpha = 0
                        }

                    case .failure:
                        // 실패하면 noInternet 이미지 띄우기
                        self.contentUnavailableView.imageResource = .noInternet
                        UIView.animate(withDuration: 0.25) {
                            self.contentUnavailableView.alpha = 1
                        }
                    }
                }
            }
        }

    // 카테고리 필터 함수
    private func handleVideoResponse(_ result: Result<PixabayResponse, Error>, page: Int) {
        switch result {
        case .success(let response):
            var fetchedVideos = response.hits

            // 카테고리 필터
            if let selectedCategory = selectedCategoryName {
                let filterCategory = selectedCategory//.lowercased()
                fetchedVideos = fetchedVideos.filter { hit in
                    let tagsArray = hit.tags
                        .split(separator: ",")
                        .map { $0.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() }
                    return tagsArray.contains(where: { $0.contains(filterCategory) })
                }
            }

            // 중복 비디오 제거
            let  existingIDs = Set(videos.map { $0.id })
            let newVideos = fetchedVideos.filter { !existingIDs.contains($0.id) }

            if page == 1 {
                videos = newVideos.shuffled()
            } else {
                videos.append(contentsOf: newVideos)
            }

            currentPage = page
            hasMoreData = fetchedVideos.count == 20
            videoCollectionView.reloadData()

        case .failure(let error):
            print(error)
        }

        videoCollectionView.refreshControl?.endRefreshing()
        isFetching = false
    }

    // Pull to Refresh 기능
    @objc private func handleRefresh() {
        guard videoCollectionView.refreshControl?.isRefreshing == true else { return }

        currentPage = 1
        hasMoreData = true
        fetchVideo(page: 1, isRepresh: true)
    }

    // 아래 스크롤할때 페이지요청함수
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView == videoCollectionView else { return }

        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.height

        // 현재위치 기준 페이지 요청( 상수변경으로 조절가능 )
        if offsetY > contentHeight - height - 200 {
            guard hasMoreData, !isFetching else { return }
            fetchVideo(page: currentPage + 1)
        }
    }

    // 개인화된 맞춤 비디오 함수
    func fetchRecentSearchQueries(limit: Int = 5) -> [String] {
        let context = CoreDataService.shared.viewContext
        let fetchRequest: NSFetchRequest<SearchRecordEntity> = SearchRecordEntity.fetchRequest()

        // 1. timestamp 기준 내림차순 정렬
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]

        do {
            let results = try context.fetch(fetchRequest)

            // 2. 중복 제거하면서 순서 유지
            var seen = Set<String>()
            var uniqueQueries: [String] = []

            for record in results {
                guard let query = record.query?.trimmingCharacters(in: .whitespacesAndNewlines),
                      !query.isEmpty else { continue }

                if seen.insert(query).inserted {
                    uniqueQueries.append(query)
                }

                if uniqueQueries.count >= limit {
                    break
                }
            }

            return uniqueQueries
        } catch {
            print("❌ 최근 검색어 가져오기 실패:", error.localizedDescription)
            return []
        }
    }

    // 선택된 카테고리에 따라 Pixabay API에서 비디오 데이터 요청
    func fetchVideo(page: Int = 1, isRepresh: Bool = false) {
        guard !isFetching else { return }
        isFetching = true

        let isAllSelected = (selectedCategoryIndex == 0)
        let dispatchGroup = DispatchGroup()
        var combinedVideos: [PixabayResponse.Hit] = []
        var keywords: [String] = []
        var keywordSet = Set<String>()

        if isAllSelected {
            let allCategories = Category.allCases.map { $0.rawValue.lowercased() }

            // 전체 카테고리에서 랜덤 1개 선택
            if let randomCategory = allCategories.randomElement(), keywordSet.insert(randomCategory).inserted {
                keywords.append(randomCategory)

            }

            // 최근 검색어 가져오기
            let recentSearches = fetchRecentSearchQueries(limit: 5).map { $0.lowercased() }

            // 검색어 2개 선별
            if recentSearches.count >= 5 {
                for search in recentSearches.shuffled().prefix(2) {
                    if keywordSet.insert(search).inserted {
                        keywords.append(search)

                    }
                }
            } else {
                // 선택된 카테고리에서 2개 랜덤 선택
                let selectedLower = selectedCategories.map { $0.lowercased() }
                for category in selectedLower.shuffled().prefix(2) {
                    if keywordSet.insert(category).inserted {
                        keywords.append(category)

                    }
                }
            }

            // 키워드 5개 채우기 (중복 없이)
            for category in allCategories.shuffled() {
                if keywordSet.count >= 5 { break }
                if keywordSet.insert(category).inserted {
                    keywords.append(category)

                }
            }

            // API 호출
            for keyword in keywords {
                let randomPage = Int.random(in: 1...10)
                dispatchGroup.enter()
                callPixabayAPI(query: keyword, page: randomPage, perPage: 3) { result in
                    if case let .success(response) = result {
                        combinedVideos.append(contentsOf: response.hits)
                    }
                    dispatchGroup.leave()
                }
            }
        } else {
            // 카테고리 선택 시
            if selectedCategoryIndex - 1 >= 0 && selectedCategoryIndex - 1 < selectedCategories.count {
                let category = selectedCategories[selectedCategoryIndex - 1].lowercased()
                dispatchGroup.enter()
                callPixabayAPI(query: category, page: page, perPage: 15) { result in
                    if case let .success(response) = result {
                        combinedVideos.append(contentsOf: response.hits)
                    }
                    dispatchGroup.leave()
                }
            }
        }

        // 완료 후 갱신
        dispatchGroup.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            if isRepresh {
                self.videos = combinedVideos.shuffled()
            } else {
                self.videos.append(contentsOf: combinedVideos.shuffled())
            }
            self.currentPage = page
            self.hasMoreData = combinedVideos.count >= 15
            self.isFetching = false

            UIView.transition(
                with: self.videoCollectionView,
                duration: 0.3,
                options: .transitionCrossDissolve,
                animations: {
                    self.videoCollectionView.reloadData()
                })

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                self.videoCollectionView.refreshControl?.endRefreshing()
            }
        }

    }

    // 동영상 재생시 시청기록재생 함수
    func addToWatchHistory(_ video: PixabayResponse.Hit) {
        let context = CoreDataService.shared.persistentContainer.viewContext

        let fetchRequest: NSFetchRequest<PlaybackHistoryEntity> = PlaybackHistoryEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %d", video.id)

        do {
            let existing = try context.fetch(fetchRequest)

            // 기존 기록이 있으면 삭제
            for record in existing {
                //  context.delete(record)
                CoreDataService.shared.delete(record)
            }
            // 새로운 시청기록 생성
            let historyEntity = video.mapToPlaybackHistoryEntity(insertInto: context)
            historyEntity.createdAt = Date()
            try context.save()
        } catch {
            print(error)
        }
    }

    // MARK: - Record PlayTime
    //    private var timeObserver: Any?
    //    private var player: AVPlayer?
    private var playTime: Double?
    private var historyList: [PixabayResponse.Hit] = []
    private var selectedVideo: PixabayResponse.Hit?

    //    private func startObservingTime(with url: URL) {
    //
    //        let interval = CMTime(seconds: 1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
    //
    //        timeObserver = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] currentTime in
    //            guard let self = self,
    //                  let duration = player?.currentItem?.duration.seconds,
    //                  duration.isFinite else { return }
    //
    //            let current = currentTime.seconds //
    //            let durationInt = Int(duration)
    //            let progress = Float(current / Double(durationInt))
    //            playTime = current
    //        }
    //    }

    private func savePlaybackHistoryToCoredata(video: PixabayResponse.Hit) {

        let context = CoreDataService.shared.persistentContainer.viewContext

        let fetchRequest: NSFetchRequest<PlaybackHistoryEntity> = PlaybackHistoryEntity.fetchRequest()
        print(type(of: video.id))
        fetchRequest.predicate = NSPredicate(format: "id == %d", video.id)


        do {
            let existing = try context.fetch(fetchRequest)

            // 기존 기록이 있으면 삭제
            for record in existing {
                // 중복 시 playTime 더 긴 것 채택
                if let playtime = self.playTime, playtime < record.playTime {
                    self.playTime = record.playTime
                }
                CoreDataService.shared.delete(record)
            }
            // 새로운 시청기록 생성
            let historyEntity = video.mapToPlaybackHistoryEntity(insertInto: context)
            historyEntity.createdAt = Date()
            historyEntity.playTime = playTime ?? PixabayResponse.Hit.defaultPlayTime
            print("historyEntity.playTime\(historyEntity.playTime)")
            try context.save()
        } catch {
            print("⚠️ Failed to save playback: \(error)")
        }
    }

    private func addHistoryVideo(_ video: PixabayResponse.Hit) {
        historyList.removeAll(where: { $0.id == video.id })
        historyList.append(video)
    }

    // 북마크
    func addToBookmark(_ video: PixabayResponse.Hit) {
        let context = CoreDataService.shared.persistentContainer.viewContext

        let bookmarkPlaylist = fetchOrCreateBookmarkPlaylist(context: context)

        let videoCheckRequest: NSFetchRequest<PlaylistVideoEntity> = PlaylistVideoEntity.fetchRequest()
        videoCheckRequest.predicate = NSPredicate(format: "id == %d And playlist == %@", video.id, bookmarkPlaylist)

        do {
            let existing = try context.fetch(videoCheckRequest)
            if !existing.isEmpty {
                Toast.makeToast("Already in bookmarks", systemName: "bookmark.fill").present()
                return
            }

            let playlistVideo = video.mapToPlaylistVideoEntity(insertInto: context)
            playlistVideo.playlist = bookmarkPlaylist
            try context.save()

            Toast.makeToast("Added to bookmarks", systemName: "bookmark").present()
        } catch {
            print(error)
        }
    }

    // 재생목록
    func addToPlaylist(_ video: PixabayResponse.Hit, at indexPath: IndexPath) {
        let context = CoreDataService.shared.persistentContainer.viewContext

        let fetchRequest: NSFetchRequest<PlaylistEntity> = PlaylistEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name != %@", CoreDataService.StaticString.bookmarkedPlaylistName)
        do {
            let playlists = try context.fetch(fetchRequest)
            let playlistNames = playlists.map { $0.name ?? ""}

            // UIAlertController로 재생목록 선택지
            let alertController = UIAlertController(title: "Select Playlist", message: nil, preferredStyle: .actionSheet)
            playlistNames.forEach { name in
                let action = UIAlertAction(title: name, style: .default) { _ in
                    self.addVideoToPlaylist(video, playlistName: name)
                }
                alertController.addAction(action)
            }

            // 새 재생목록 생성 옵션 추가
            let createNewAction = UIAlertAction(title: "Create New Playlist", style: .default) { _ in
                self.showAddPlaylistAlert()

            }
            alertController.addAction(createNewAction)

            // 취소 버튼 추가
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
            alertController.addAction(cancelAction)

            // iPad 대응: Popover 설정
            if let popover = alertController.popoverPresentationController {
                guard let cell = videoCollectionView.cellForItem(at: indexPath) as? VideoCell,
                      let ellipsisButton = cell.ellipsisButton else { return }

                popover.sourceView = ellipsisButton
                popover.sourceRect = ellipsisButton.bounds
                popover.permittedArrowDirections = [.up, .down]
            }

            self.present(alertController, animated: true)

        } catch {
            print(error)
        }
    }

    // 재생목록 리스트
    func addVideoToPlaylist(_ video: PixabayResponse.Hit, playlistName: String) {
        let context = CoreDataService.shared.persistentContainer.viewContext

        // 선택한 재생목록 찾기
        let fetchRequest: NSFetchRequest<PlaylistEntity> = PlaylistEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", playlistName)
        do {
            if let playlist = try context.fetch(fetchRequest).first {
                // 중복체크
                if let videos = playlist.playlistVideos as? Set<PlaylistVideoEntity> {
                    let isDuplicate = videos.contains { $0.id == video.id }

                    if isDuplicate {
                        Toast.makeToast("Already in '\(playlistName)'", systemName: "exclamationmark.triangle").present()
                        return
                    }
                }
                // PlaylistVideoEntity 생성 및 저장
                let playlistVideo = video.mapToPlaylistVideoEntity(insertInto: context)
                playlist.addToPlaylistVideos(playlistVideo)
                try context.save()
                Toast.makeToast("Added to '\(playlistName)'", systemName: "list.clipboard").present()
            }
        } catch {
            print(error)
        }
    }

    // 재생목록 만들 시 필요함수
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

    // 재생목록 만드는 함수
    func createPlaylist(name: String, video: PixabayResponse.Hit) {
        let context = CoreDataService.shared.persistentContainer.viewContext

        // 새로운 재생목록엔티티 생성
        let newPlaylist = PlaylistEntity(context: context)
        newPlaylist.name = name
        newPlaylist.createdAt = Date()

        // 재생목록앤티티 생성 및 저장
        let playlistVideo = video.mapToPlaylistVideoEntity(insertInto: context)
        newPlaylist.addToPlaylistVideos(playlistVideo)

        do {
            try context.save()
        } catch {
            print(error)
        }
    }

    // 북마크 갱신함수
    func fetchOrCreateBookmarkPlaylist(context: NSManagedObjectContext) -> PlaylistEntity {
        let request: NSFetchRequest<PlaylistEntity> = PlaylistEntity.fetchRequest()
        request.predicate = NSPredicate(format: "name == %@", CoreDataString.bookmarkedPlaylistName)

        if let existing = try? context.fetch(request), let playlist = existing.first {
            return playlist
        } else {
            let newPlaylist = PlaylistEntity(context: context)
            newPlaylist.name = CoreDataString.bookmarkedPlaylistName
            newPlaylist.createdAt = Date()
            try? context.save()
            return newPlaylist
        }
    }

    // MARK: - 아이패드 대응

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        if let alert = presentedViewController as? UIAlertController {
            alert.dismiss(animated: true)
        }

        coordinator.animate(alongsideTransition: nil) { _ in
            self.videoCollectionView.reloadData()
        }
    }
    // 다크모드 적용
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        categoryCollectionView.reloadData()
        videoCollectionView.collectionViewLayout.invalidateLayout()
    }
}


extension HomeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == categoryCollectionView {
            // 선택한 카테고리 인덱스 업데이트
            selectedCategoryIndex = indexPath.item
            // 카테고리 컬렉션뷰 다시 그리기 (선택 상태 반영)
            categoryCollectionView.reloadData()
            // 선택된 셀로 스크롤
            categoryCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            // 맨 위로 스크롤
            videoCollectionView.setContentOffset(.zero, animated: true)
            // 선택한 카테고리에 맞춰 비디오 재요청(초기화)
            fetchVideo(page: 1, isRepresh: true)
        }
    }

    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        guard collectionView == videoCollectionView,
              indexPath.item < videos.count else { return nil }
        let item = videos[indexPath.item]

        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            let bookmarkAction = UIAction(
                title: "Add to Bookmarks", image: UIImage(systemName: "bookmark")
            ) { _ in
                self.addToBookmark(item)
            }

            let playlistAction = UIAction(
                title: "Add to Playlist", image: UIImage(systemName: "text.badge.plus")
            ) { _ in
                self.addToPlaylist(item, at: indexPath)
            }

            return UIMenu(title: "", children: [bookmarkAction, playlistAction])
        }
    }
}

extension HomeViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == videoCollectionView {
            return videos.count
        }
        return displayedCategories.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        if collectionView == videoCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoCell", for: indexPath) as! VideoCell
            let video = videos[indexPath.item]

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

            // MARK: - 썸네일 터치시 영상 재생
            cell.onThumbnailTap = { [weak self] in
                guard let self = self else { return }

                self.selectedVideo = video

                videoPlayerService.playVideo(self, with: video) { time in
                    print("\(time.seconds)")
                    self.playTime = time.seconds
                } onError: { error in
                    switch error {
                    case .notConnectedToInternet:
                        self.showAlert(
                            title: "No Internet Connection",
                            message: "Please check your internet connection.",
                            onPrimary: { _ in }
                        )
                    case .generic(let err):
                        print("Generic error occurred", err.localizedDescription)
                    case .none:
                        self.addHistoryVideo(video)
                    }
                }
            }

            cell.onTagTap = { [weak self] tag in
                guard let self = self else { return }

                // 본인 인덱스는 제외
                let currentIndex = indexPath.item

                // 본인 인덱스 제외 첫번째 영상찾기
                if let index = self.videos.enumerated().first(where: { offset, hit in
                    guard offset != currentIndex else { return false }
                    let tags = hit.tags
                        .split(separator: ",")
                        .map { $0.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() }
                    return tags.contains(tag.lowercased())
                })?.offset {
                    let indexPath = IndexPath(item: index, section: 0)
                    self.videoCollectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: true)
                    Toast.makeToast("Found tag: '\(tag)'", systemName: "lightbulb.max.fill").present()
                } else {
                    Toast.makeToast("Not Found tag: '\(tag)'", systemName: "questionmark.circle").present()
                }
            }



            // Ellipsis 버튼 실행
            cell.configureMenu(

                bookmarkAction: { [weak self] in
                    self?.addToBookmark(video)
                },
                playlistAction: { [weak self] in
                    self?.addToPlaylist(video, at: indexPath)
                }
            )
            return cell
        }

        if collectionView == categoryCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCell", for: indexPath) as! CategoryCell

            let title = displayedCategories[indexPath.item]
            let isSelected = (indexPath.item == selectedCategoryIndex)
            cell.configure(with: title.capitalized, selected: isSelected)
            return cell
        }
        fatalError("Unknown collection view")
    }
}

extension HomeViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == videoCollectionView {
            let size = collectionView.bounds.size
            let isPad = UIDevice.current.userInterfaceIdiom == .pad
            let isPortrait = size.height > size.width
            let columns: CGFloat = isPad ? (isPortrait ? 2 : 3) : 1

            let spacing: CGFloat = 8
            let totalSpacing = spacing * (columns - 1)
            let width = (size.width - totalSpacing) / columns
            let height = width * 9 / 16 + 60

            return CGSize(width: width, height: height)
        }

        // 카테고리
        let text = displayedCategories[indexPath.item]
        let font = UIFont.systemFont(ofSize: 16)
        let width = text.size(withAttributes: [.font: font]).width + 32
        return CGSize(width: width, height: 40)
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

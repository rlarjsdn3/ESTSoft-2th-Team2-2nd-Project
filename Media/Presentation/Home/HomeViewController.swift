
import UIKit
import AVKit
import AVFoundation
import CoreData


final class HomeViewController: StoryboardViewController {
    private var selectedVideoURL: URL?

    private var observation: NSKeyValueObservation?


    @IBAction func SearchButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: "SearchViewController", bundle: nil)
        if let searchVC = storyboard.instantiateViewController(withIdentifier: "SearchViewController") as? SearchViewController {
            navigationController?.pushViewController(searchVC, animated: true)
        }
    }

    @IBOutlet weak var categoryCollectionView: UICollectionView!

    // 초기값설정
    var selectedCategoryIndex: Int = 0

    // 임시 코드 수정예정
    //    var selectedCategories: [Category] = [.fashion, .music, .business, .food, .health]
    //    var selectedCategories: [Category] = []
    var selectedCategories: [String] = ["Flower", "Nature", "Animals", "Travel", "Food"]

    // 카테고리 배열 순서
    var displayedCategories: [String] {

        return ["All"] + selectedCategories
    }

    // 필터링 소문자로 비교
    var selectedCategoryName: String? {
        if selectedCategoryIndex == 0 {
            return nil
        }
        return selectedCategories[selectedCategoryIndex - 1].lowercased()
    }

    @IBOutlet weak var videoCollectionView: UICollectionView!

    //Parameter : Pull to Refresh 기능
    @objc private func handleRefresh() {
        guard videoCollectionView.refreshControl?.isRefreshing == true else { return }

        fetchVideo()
    }

    let service = DefaultDataTransferService()

    // Pixabay API에서 받아온 비디오 데이터 배열
    private var videos: [PixabayResponse.Hit] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        //        NotificationCenter.default.addObserver(forName: .didSelectedCategories, object: nil, queue: .main) { [weak self]_ in
        //            self?.selectedCategories = TagsDataManager.shared.fetchSeletedCategories()
        //            self?.categoryCollectionView.reloadData()
        //            self?.fetchVideo()
        //        }


        //       selectedCategories = TagsDataManager.shared.fetchSeletedCategories()

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

        videoCollectionView.contentInset = .zero

        if let layout = videoCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.sectionInset = .zero
            layout.minimumInteritemSpacing = 0
            layout.minimumLineSpacing = 0
            layout.invalidateLayout()
        }
        //Pull to Refresh 기능
        let  refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        videoCollectionView.refreshControl = refreshControl

        fetchVideo()

    }



    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)

    }
    //UIView controller Extention

    // "mm:ss" 형식으로 문자열 변환
    func formatDuration(seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }

        // 비디오 재생
    func playVideo(with url: URL) {
        print("▶️ playVideo called with URL: \(url.absoluteString)")
        // #1. PlayerItem 생성
        let item = AVPlayerItem(url: url)
        print("🔹 AVPlayerItem created")
        // #2. Player 생성
        let player = AVPlayer(playerItem: item)
        print("🔹 AVPlayer created")
        // #3. PlayerVC 생성
        let vc = AVPlayerViewController()
        print("🔹 AVPlayerViewController created")
        // #4. 연결
        vc.player = player
        print("🔹 Player connected to PlayerViewController")
        // #5. 표시
        present(vc, animated: true) {
            print("🔹 PlayerViewController presented")
        }
        
        observation?.invalidate()
        print("🔹 Previous observation invalidated")
        
        observation = item.observe(\.status) { playerItem, _ in
            print("🔸 PlayerItem status changed: \(playerItem.status.rawValue)")
            
            if playerItem.status == .readyToPlay {
                print("✅ PlayerItem is ready to play, starting playback")
                
                player.play()
            } else if playerItem.status == .failed {
                print("❌ PlayerItem failed to load\(playerItem.error.debugDescription)")
            }
        }
    }

    // 선택된 카테고리에 따라 Pixabay API에서 비디오 데이터 요청
    func fetchVideo() {
        let query = selectedCategoryName

        let endpoint = APIEndpoints.pixabay(
            query: query,
            category: nil,
            order: .popular,
            page: 1,
            perPage: 20
        )


        let startTime = Date()

        service.request(endpoint) { [weak self] result in
            DispatchQueue.main.async {
                guard let  self = self else { return }
                // Refresh 딜레이 추가
                let elapsed = Date().timeIntervalSince(startTime)
                let delay = max(0.5 - elapsed, 0)

                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    self.videoCollectionView.refreshControl?.endRefreshing()


                    switch result {
                    case .success(let response):
                        var fetchedVideos = response.hits

                        if let selectedCategory = self.selectedCategoryName {
                            // 선택한 카테고리(소문자)
                            let filterCategory = selectedCategory.lowercased()
                            // 첫번째 태그 기준 필터링
                            fetchedVideos = fetchedVideos
                                .filter { hit in
                                    let tags = hit.tags.split(separator: ",")
                                        .map { $0.trimmingCharacters(in: .whitespacesAndNewlines)
                                                .lowercased()
                                        }
                                    return tags.contains(filterCategory)
                                }
                        }
                        self.videos = fetchedVideos
                        self.categoryCollectionView.reloadData()
                        self.videoCollectionView.reloadData()

                    case .failure(let error):
                        print(error)
                    }
                }
            }
        }
    }

    // 재생목록 비어있는지 체크
    var playlistIsEmmpty: Bool = false



    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // 테스트용
        //                if let testURL = URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4") {
        //                    playVideo(with: testURL)
        //                }

        //        if let testURL = URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4") {
        //            playVideo(with: testURL)
        //        }

        //        if let testURL = URL(string: "https://kxc.blob.core.windows.net/est2/video-vert.mp4") {
        //            playVideo(with: testURL)
        //        }
    }


    // 비디오 테스트용

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

    // 북마크
    func addToBookmark(_ video: PixabayResponse.Hit) {
        let context = CoreDataService.shared.persistentContainer.viewContext

        let bookmarkPlaylist = fetchOrCreateBookmarkPlaylist(context: context)

        let videoCheckRequest: NSFetchRequest<PlaylistVideoEntity> = PlaylistVideoEntity.fetchRequest()
        videoCheckRequest.predicate = NSPredicate(format: "id == %d And playlist == %@", video.id, bookmarkPlaylist)

        do {
            let existing = try context.fetch(videoCheckRequest)
            if !existing.isEmpty {
                Toast.makeToast("이미 북마크에 있습니다", systemName: "bookmark.fill").present()
                return
            }

            let playlistVideo = video.mapToPlaylistVideoEntity(insertInto: context)
            playlistVideo.playlist = bookmarkPlaylist
            try context.save()

            Toast.makeToast("북마크에 추가되었습니다", systemName: "bookmark").present()
        } catch {
            print(error)
        }
    }
    // 재생목록
    func addToPlaylist(_ video: PixabayResponse.Hit) {
        let context = CoreDataService.shared.persistentContainer.viewContext

        let fetchRequest: NSFetchRequest<PlaylistEntity> = PlaylistEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name != %@", CoreDataService.StaticString.bookmarkedPlaylistName)
        do {
            let playlists = try context.fetch(fetchRequest)
            let playlistNames = playlists.map { $0.name ?? ""}

            // UIAlertController로 재생목록 선택지
            let alertController = UIAlertController(title: "재생목록 선택", message: nil, preferredStyle: .actionSheet)
            playlistNames.forEach { name in
                let action = UIAlertAction(title: name, style: .default) { _ in
                    self.addVideoToPlaylist(video, playlistName: name)
                }
                alertController.addAction(action)
            }

            // 새 재생목록 생성 옵션 추가
            let createNewAction = UIAlertAction(title: "새 재생목록 만들기", style: .default) { _ in
                self.showAddPlaylistAlert()

            }
            alertController.addAction(createNewAction)

            // 취소 버튼 추가
            let cancelAction = UIAlertAction(title: "취소", style: .cancel)
            alertController.addAction(cancelAction)

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
                // PlaylistVideoEntity 생성 및 저장
                let playlistVideo = video.mapToPlaylistVideoEntity(insertInto: context)
                playlist.addToPlaylistVideos(playlistVideo)
                try context.save()
                Toast.makeToast("재생목록에 추가되었습니다", systemName: "list.clipboard").present()
            }
        } catch {
            print(error)
        }
    }

    // 재생목록 만들 시 필요함수
    func showAddPlaylistAlert() {

        showTextFieldAlert(
            "새로운 재생 목록 추가",message: "새로운 재생 목록 이름을 입력하세요.") { (action, newText) in
                if !PlaylistEntity.isExist(newText) {
                    let newPlaylist = PlaylistEntity(
                        name: newText,
                        insertInto: CoreDataService.shared.viewContext
                    )
                    CoreDataService.shared.insert(newPlaylist)
                    Toast.makeToast("'\(newPlaylist.name)'생성되었습니다", systemName: "list.clipboard").present()

                } else {
                    Toast.makeToast("이미 존재하는 재생 목록 이름입니다.").present()
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
}


extension HomeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == categoryCollectionView {
            // 선택한 카테고리 인덱스 업데이트
            selectedCategoryIndex = indexPath.item
            // 카테고리 컬렉션뷰 다시 그리기 (선택 상태 반영)
            categoryCollectionView.reloadData()
            // 선택한 카테고리에 맞춰 비디오 재요청
            fetchVideo()
        }
    }

    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        guard collectionView == videoCollectionView,
              indexPath.item < videos.count else { return nil }
        let item = videos[indexPath.item]

        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            let bookmarkAction = UIAction(
                title: "북마크에 추가하기", image: UIImage(systemName: "bookmark")
            ) { _ in
                self.addToBookmark(item)
            }

            let playlistAction = UIAction(
                title: "재생목록에 추가하기", image: UIImage(systemName: "text.badge.plus")
            ) { _ in
                self.addToPlaylist(item)
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

            // 썸네일 터치시 영상 재생
            cell.onThumbnailTap = { [weak self] in
                guard let self = self, let videoURL = video.videos.medium.url else { return }
                // 시청기록 저장
                self.addToWatchHistory(video)
                // 영상재생
                self.playVideo(with: videoURL)
            }

            // Ellipsis 버튼 실행
            cell.configureMenu(

                bookmarkAction: { [weak self] in
                    self?.addToBookmark(video)
                },
                playlistAction: { [weak self] in
                    self?.addToPlaylist(video)
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
            let width = collectionView.bounds.width
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


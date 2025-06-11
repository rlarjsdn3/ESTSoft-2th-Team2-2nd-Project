
import UIKit
import AVKit
import AVFoundation

final class HomeViewController: StoryboardViewController {

    @IBAction func SearchButton(_ sender: Any) {
        let sb = UIStoryboard(name: "SearchViewController", bundle: nil)
        let searchVC = sb.instantiateViewController(identifier: "SearchViewController") as! SearchViewController

        navigationController?.pushViewController(searchVC, animated: true)
    }

    @IBOutlet weak var categoryCollectionView: UICollectionView!

    // 초기값설정
    var selectedCategoryIndex: Int = 0

    // 임시 코드 수정예정
    var selectedCategories: [String] = ["Flower", "Nature", "Animals", "Travel", "Food"]

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


    override func viewDidLoad() {
        super.viewDidLoad()

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

    // "mm:ss" 형식으로 문자열 변환
    func formatDuration(seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }

    // 선택된 카테고리에 따라 Pixabay API에서 비디오 데이터 요청
    private func fetchVideo() {
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
                            fetchedVideos = fetchedVideos.filter { hit in
                                let firstTag = hit.tags.split(separator: ",").first?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
                                return firstTag == filterCategory
                            }
                        }
                        self.videos = fetchedVideos
                        self.categoryCollectionView.reloadData()
                        self.videoCollectionView.reloadData()

                    case .failure(let error):
                        print("Fetch videos error:", error)
                    }
                }
            }
        }
    }
}

extension HomeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == categoryCollectionView {
            if selectedCategoryIndex != indexPath.item {
                selectedCategoryIndex = indexPath.item
                categoryCollectionView.reloadData()

                let selectedTitle = displayedCategories[indexPath.item]
                print("\(selectedTitle)")

                fetchVideo()

            }
        } else if collectionView == videoCollectionView {
            let video = videos[indexPath.item]
            let urlString = video.videos.medium.url

            guard let url = video.videos.medium.url else {
                return
            }


            let player = AVPlayer(url: url)
            let playerViewController = AVPlayerViewController()
            playerViewController.player = player
            present(playerViewController, animated: true) {
                player.play()
            }
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

        if collectionView == categoryCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCell", for: indexPath) as! CategoryCell

            let title = displayedCategories[indexPath.item]
            let isSelected = (indexPath.item == selectedCategoryIndex)
            cell.configure(with: title.capitalized, selected: isSelected)
            return cell
        } else if collectionView == videoCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoCell", for: indexPath) as! VideoCell
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

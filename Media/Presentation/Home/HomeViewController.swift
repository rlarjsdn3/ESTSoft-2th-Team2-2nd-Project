
import UIKit

final class HomeViewController: StoryboardViewController {

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
    var selectedCategories: [Category] = [.fashion, .music, .business, .food, .health]

    var displayedCategories: [String] {
        return ["All"] + selectedCategories.map{ $0.rawValue }
    }


    @IBOutlet weak var videoCollectionView: UICollectionView!


    let service = DefaultDataTransferService()

    // Pixabay API에서 받아온 비디오 데이터 배열
    private var videos: [PixabayResponse.Hit] = []

    

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
        let category: Category? = selectedCategoryIndex == 0 ? nil : selectedCategories[selectedCategoryIndex - 1]

        let endpoint = APIEndpoints.pixabay(
            query: nil,
            category: category,
            order: .popular,
            page: 1,
            perPage: 20
        )

        service.request(endpoint) { [weak self] result in
            switch result {
            case .success(let response):
                self?.videos = response.hits
                DispatchQueue.main.async {
                    self?.videoCollectionView.reloadData()
                }
            case .failure(let error):
                print("Fetch videos error:", error)
            }
        }
    }
}

extension HomeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == categoryCollectionView {
            if collectionView == categoryCollectionView {
                selectedCategoryIndex = indexPath.item
                categoryCollectionView.reloadData()

                fetchVideo()
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
                    viewCountText: "Views: \(video.views)",
                    durationText: formatDuration(seconds: video.duration),
                    thumbnailURL: video.videos.medium.thumbnail,
                    profileImageURL: video.userImageUrl
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
            let height = width * 9 / 16 + 80
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

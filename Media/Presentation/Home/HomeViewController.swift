
import UIKit

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
    var selectedCategories: [Category] = [.fashion, .music, .business, .food, .health]

    var displayedCategories: [String] {
        return ["All"] + selectedCategories.map{ $0.rawValue }
    }


    @IBOutlet weak var videoCollectionView: UICollectionView!


    let service = DefaultDataTransferService()

    override func viewDidLoad() {
        super.viewDidLoad()


        categoryCollectionView.delegate = self
        categoryCollectionView.dataSource = self
        categoryCollectionView.register(UINib(nibName: "CategoryCell", bundle: nil), forCellWithReuseIdentifier: "CategoryCell")

        videoCollectionView.delegate = self
        videoCollectionView.dataSource = self
        videoCollectionView.register(UINib(nibName: "VideoCell", bundle: nil), forCellWithReuseIdentifier: "VideoCell")



    }
}

extension HomeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == categoryCollectionView {
            if collectionView == categoryCollectionView {
                selectedCategoryIndex = indexPath.item
                categoryCollectionView.reloadData()

                let selectedTitle = displayedCategories[indexPath.item]
                print("\(selectedTitle)")
            }
        }
    }
}

extension HomeViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return displayedCategories.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
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
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == categoryCollectionView {
            let height: CGFloat = 40
            let text = displayedCategories[indexPath.item]
            let font = UIFont.systemFont(ofSize: 16)
            let width = text.size(withAttributes: [.font: font]).width + 32
            return CGSize(width: width, height: height)
        }
        return CGSize(width: 100, height: 100)
    }

    // 셀 사이 간격
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
}

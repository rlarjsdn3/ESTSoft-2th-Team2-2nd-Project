
import UIKit

final class HomeViewController: StoryboardViewController {


    @IBAction func SearchButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: "SearchViewController", bundle: nil)
        if let searchVC = storyboard.instantiateViewController(withIdentifier: "SearchViewController") as? SearchViewController {
            navigationController?.pushViewController(searchVC, animated: true)
        }
    }

    let service = DefaultDataTransferService()

    override func viewDidLoad() {
        super.viewDidLoad()

        let list: [PlaybackHistoryEntity]? = try? CoreDataService.shared.fetch()
        print(list)
    }
}


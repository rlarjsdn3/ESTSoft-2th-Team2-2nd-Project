//
//  SearchFilterViewController.swift
//  Media
//
//  Created by 백현진 on 6/9/25.
//

import UIKit

class SearchFilterViewController: StoryboardViewController {

    @IBOutlet weak var filterCategoryCollectionView: UICollectionView!

    @IBOutlet weak var filterDateCollectionView: UICollectionView!

    @IBOutlet weak var filterVideoDurationCollectionView: UICollectionView!

    private let categories = Category.allCases

    override func viewDidLoad() {
        super.viewDidLoad()
        registerCollectionViews()
    }

    override func setupHierachy() {
    }

    private func registerCollectionViews() {
        if let flow = filterCategoryCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flow.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
            flow.minimumInteritemSpacing = 8
            flow.minimumLineSpacing = 8
            flow.sectionInset = .init(top: 0, left: 16, bottom: 0, right: 16)
        }
        if let flow = filterDateCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flow.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
            flow.minimumInteritemSpacing = 8
            flow.minimumLineSpacing = 8
            flow.sectionInset = .init(top: 0, left: 16, bottom: 0, right: 16)
        }
        if let flow = filterVideoDurationCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flow.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
            flow.minimumInteritemSpacing = 8
            flow.minimumLineSpacing = 8
            flow.sectionInset = .init(top: 0, left: 16, bottom: 0, right: 16)
        }

        filterCategoryCollectionView.delegate = self
        filterCategoryCollectionView.dataSource = self

        filterDateCollectionView.delegate = self
        filterDateCollectionView.dataSource = self

        filterVideoDurationCollectionView.delegate = self
        filterVideoDurationCollectionView.dataSource = self
    }

    override func setupAttributes() {
        self.view.backgroundColor = UIColor.background
    }
}

extension SearchFilterViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case filterCategoryCollectionView:
            return categories.count
        case filterDateCollectionView:
            return 3
        case filterVideoDurationCollectionView:
            return 3
        default:
            return 0
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView {
        case filterCategoryCollectionView:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FilterCategoryCollectionViewCell.id, for: indexPath) as! FilterCategoryCollectionViewCell

            let target = categories[indexPath.item]
            cell.categoryContentView.layer.cornerRadius = 12
            cell.categoryContentView.backgroundColor = .blue
            cell.categoryLabel.text = target.rawValue

            return cell
        case filterDateCollectionView:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FilterDateCollectionViewCell.id, for: indexPath) as! FilterDateCollectionViewCell
            cell.dateContentView.layer.cornerRadius = 12
            cell.dateContentView.backgroundColor = .blue
            cell.dateLabel.text = "12월"
            return cell
        case filterVideoDurationCollectionView:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FilterVideoDurationCollectionViewCell.id, for: indexPath) as! FilterVideoDurationCollectionViewCell
            cell.durationContentView.layer.cornerRadius = 12
            cell.durationContentView.backgroundColor = .blue
            cell.durationLabel.text = "오늘"
            return cell
        default:
            return UICollectionViewCell()
        }
    }
}

extension SearchFilterViewController: UICollectionViewDelegate {

}



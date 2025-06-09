//
//  SearchFilterViewController.swift
//  Media
//
//  Created by 백현진 on 6/9/25.
//

import UIKit

class SearchFilterViewController: StoryboardViewController {

    @IBOutlet weak var containerUIView: UIView!

    @IBOutlet weak var filterCategoryCollectionView: UICollectionView!

    @IBOutlet weak var filterDateCollectionView: UICollectionView!

    @IBOutlet weak var filterVideoDurationCollectionView: UICollectionView!

    @IBOutlet weak var filterCategoryCVHeightConstraint: NSLayoutConstraint!

    private let categories = Category.allCases

    //임시 데이터
    private let dates = ["지난 1시간", "오늘", "이번 주", "이번 달", "올해"]
    private let durations = ["10초 미만", "10~30초", "1분 초과"]
    //popular/ latest 추가 해야함

    override func viewDidLoad() {
        super.viewDidLoad()

        registerCollectionViews()
        if let flow = filterCategoryCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flow.scrollDirection = .horizontal
        }
        filterCategoryCVHeightConstraint.constant = 40
    }

    override func setupHierachy() {
    }

    override func setupAttributes() {
        self.view.backgroundColor = UIColor.background
        self.containerUIView.backgroundColor = UIColor.background
        filterCategoryCollectionView.backgroundColor = .clear
        filterDateCollectionView.backgroundColor = .clear
        filterVideoDurationCollectionView.backgroundColor = .clear
	}

    @IBAction func applyButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true)
    }

    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    

    private func registerCollectionViews() {
        collectionViewInset(collectionView: filterCategoryCollectionView)
        collectionViewInset(collectionView: filterDateCollectionView)
        collectionViewInset(collectionView: filterVideoDurationCollectionView)

        filterCategoryCollectionView.delegate = self
        filterCategoryCollectionView.dataSource = self

        filterDateCollectionView.delegate = self
        filterDateCollectionView.dataSource = self

        filterVideoDurationCollectionView.delegate = self
        filterVideoDurationCollectionView.dataSource = self
    }

    // collectionView Inset setting
    private func collectionViewInset(collectionView: UICollectionView) {
        if let flow = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flow.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
            flow.minimumInteritemSpacing = 8
            flow.minimumLineSpacing = 8
            flow.sectionInset = .init(top: 0, left: 16, bottom: 0, right: 16)
        }
    }
}

extension SearchFilterViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case filterCategoryCollectionView:
            return categories.count
        case filterDateCollectionView:
            return dates.count
        case filterVideoDurationCollectionView:
            return durations.count
        default:
            return 0
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView {
        case filterCategoryCollectionView:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FilterCategoryCollectionViewCell.id, for: indexPath) as! FilterCategoryCollectionViewCell

            let target = categories[indexPath.item]
            cell.defaultCellConfigure()
            cell.categoryLabel.text = target.rawValue

            return cell
        case filterDateCollectionView:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FilterDateCollectionViewCell.id, for: indexPath) as! FilterDateCollectionViewCell

            let target = dates[indexPath.item]
            cell.defaultCellConfigure()
            cell.dateLabel.text = target
            return cell
        case filterVideoDurationCollectionView:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FilterVideoDurationCollectionViewCell.id, for: indexPath) as! FilterVideoDurationCollectionViewCell

            let target = durations[indexPath.item]
            cell.defaultCellConfigure()
            cell.durationLabel.text = target
            return cell
        default:
            return UICollectionViewCell()
        }
    }
}

extension SearchFilterViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }
}

extension SearchFilterViewController: UISheetPresentationControllerDelegate {
    func sheetPresentationControllerDidChangeSelectedDetentIdentifier(
        _ sheetPresentationController: UISheetPresentationController
    ) {
        guard let detent = sheetPresentationController.selectedDetentIdentifier,
              let flow = filterCategoryCollectionView.collectionViewLayout as? UICollectionViewFlowLayout
        else { return }

        switch detent {
        case .large:
            flow.scrollDirection = .vertical
            filterCategoryCVHeightConstraint.constant = 240
        default:
            flow.scrollDirection = .horizontal
            filterCategoryCVHeightConstraint.constant = 40

        }

        flow.invalidateLayout()

        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }
}


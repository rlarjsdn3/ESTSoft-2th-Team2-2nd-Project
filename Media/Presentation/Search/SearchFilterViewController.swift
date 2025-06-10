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
    private var selectedCategories: Set<Category> = []

    //임시 데이터
    private let dates = ["지난 1시간", "오늘", "이번 주", "이번 달", "올해"]
    private var selectedDate: String?

    private let durations = ["10초 미만", "10~30초", "1분 초과"]
    private var selectedDuration: String?

    //popular/ latest 추가 해야함

    override func viewDidLoad() {
        super.viewDidLoad()

        registerCollectionViews()
        if let flow = filterCategoryCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flow.scrollDirection = .horizontal
        }
        filterCategoryCVHeightConstraint.constant = 40
        filterCategoryCollectionView.allowsMultipleSelection = true
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
        print(selectedCategories, selectedDate, selectedDuration)
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
        switch collectionView {

            // 카테고리 다중 선택
        case filterCategoryCollectionView:
            let category = categories[indexPath.item]
            if selectedCategories.contains(category) {
                // 이미 선택돼 있었으면 해제
                selectedCategories.remove(category)
                collectionView.deselectItem(at: indexPath, animated: true)
            } else {

                selectedCategories.insert(category)
            }

            // 날짜: 단일 선택
        case filterDateCollectionView:
            // 이전 선택이 있으면 해제
            if let prev = selectedDate,
               let prevIndex = dates.firstIndex(of: prev) {
                let prevPath = IndexPath(item: prevIndex, section: 0)
                collectionView.deselectItem(at: prevPath, animated: true)
            }
            // 새로 선택
            selectedDate = dates[indexPath.item]

            // 길이: 단일 선택
        case filterVideoDurationCollectionView:
            if let prev = selectedDuration,
               let prevIndex = durations.firstIndex(of: prev) {
                let prevPath = IndexPath(item: prevIndex, section: 0)
                collectionView.deselectItem(at: prevPath, animated: true)
            }
            selectedDuration = durations[indexPath.item]

        default:
            break
        }
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        switch collectionView {

            // 카테고리는 다중 선택 → deselect 시에도 상태 업데이트
        case filterCategoryCollectionView:
            let category = categories[indexPath.item]
            selectedCategories.remove(category)

            // date/duration 은 위 didSelectItemAt에서 직접 해제하므로 여기선 특별히 처리할 필요 없음
        default:
            break
        }
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


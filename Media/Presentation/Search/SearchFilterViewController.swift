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

    @IBOutlet weak var filterOrderCollectionView: UICollectionView!

    @IBOutlet weak var filterVideoDurationCollectionView: UICollectionView!

    @IBOutlet weak var filterCategoryCVHeightConstraint: NSLayoutConstraint!

    private let categories = Category.allCases
    var selectedCategories: Set<Category> = []

    private let orders = Order.allCases
    var selectedOrder: Set<Order> = []

    private let durations: [Duration] = Duration.allCases
    var selectedDuration: Set<Duration> = []

    // 조건 검색을 위한 클로저 프로퍼티
    var onApply: ((_ categories: Set<Category>,
                   _ order: Set<Order>,
                   _ duration: Set<Duration>) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        print(selectedCategories, selectedOrder, selectedDuration)
    }

    override func setupHierachy() {
        registerCollectionViews()
        if let flow = filterCategoryCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flow.scrollDirection = .horizontal
        }
        filterCategoryCVHeightConstraint.constant = 40
        filterCategoryCollectionView.allowsMultipleSelection = false
    }

    override func setupAttributes() {
        self.view.backgroundColor = UIColor.background
        self.containerUIView.backgroundColor = UIColor.background
        filterCategoryCollectionView.backgroundColor = .clear
        filterOrderCollectionView.backgroundColor = .clear
        filterVideoDurationCollectionView.backgroundColor = .clear
    }

    @IBAction func applyButtonTapped(_ sender: UIButton) {
        onApply?(selectedCategories, selectedOrder, selectedDuration)
        dismiss(animated: true)
    }

    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true)
    }

    private func registerCollectionViews() {
        collectionViewInset(collectionView: filterCategoryCollectionView)
        collectionViewInset(collectionView: filterOrderCollectionView)
        collectionViewInset(collectionView: filterVideoDurationCollectionView)

        filterCategoryCollectionView.delegate = self
        filterCategoryCollectionView.dataSource = self

        filterOrderCollectionView.delegate = self
        filterOrderCollectionView.dataSource = self

        filterVideoDurationCollectionView.delegate = self
        filterVideoDurationCollectionView.dataSource = self
    }
}



//MARK: - CollectionView Delegate

extension SearchFilterViewController: UICollectionViewDataSource	 {
    // collectionView Inset setting
    private func collectionViewInset(collectionView: UICollectionView) {
        if let flow = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flow.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
            flow.minimumInteritemSpacing = 8
            flow.minimumLineSpacing = 8
            flow.sectionInset = .init(top: 0, left: 16, bottom: 0, right: 16)
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case filterCategoryCollectionView:
            return categories.count
        case filterOrderCollectionView:
            return orders.count
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
        case filterOrderCollectionView:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FilterOrderCollectionViewCell.id, for: indexPath) as! FilterOrderCollectionViewCell

            let target = orders[indexPath.item]
            cell.defaultCellConfigure()
            cell.orderLabel.text = target.rawValue

            return cell
        case filterVideoDurationCollectionView:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FilterVideoDurationCollectionViewCell.id, for: indexPath) as! FilterVideoDurationCollectionViewCell

            let target = durations[indexPath.item]
            cell.defaultCellConfigure()
            cell.durationLabel.text = target.description

            return cell
        default:
            return UICollectionViewCell()
        }
    }
}

extension SearchFilterViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch collectionView {

            // 카테고리: 단일 선택
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
        case filterOrderCollectionView:
            let order = orders[indexPath.item]
            if selectedOrder.contains(order) {
                // 이미 선택돼 있었으면 해제
                selectedOrder.remove(order)
                collectionView.deselectItem(at: indexPath, animated: true)
            } else {
                selectedOrder.insert(order)
            }

            // 길이: 단일 선택
        case filterVideoDurationCollectionView:
            let duration = durations[indexPath.item]
            if selectedDuration.contains(duration) {
                // 이미 선택돼 있었으면 해제
                selectedDuration.remove(duration)
                collectionView.deselectItem(at: indexPath, animated: true)
            } else {
                selectedDuration.insert(duration)
            }
        default:
            break
        }
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        switch collectionView {
        case filterCategoryCollectionView:
            let category = categories[indexPath.item]
            selectedCategories.remove(category)
        case filterOrderCollectionView:
            let order = orders[indexPath.item]
            selectedOrder.remove(order)
        case filterVideoDurationCollectionView:
            let duration = durations[indexPath.item]
            selectedDuration.remove(duration)
        default:
            break
        }
    }
}

 // MARK: - Detent
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


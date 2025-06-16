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

    private let orders = Order.allCases

    private let durations: [Duration] = Duration.allCases

    private let dataService: DataTransferService = DefaultDataTransferService()

    private var selectedCategories: Category? = {
        let raw: String? = UserDefaultsService.shared[keyPath: \.filterCategories]

        return raw.flatMap { Category(rawValue: $0) }
    }()

    private var selectedOrder: Order? = {
        let raw: String? = UserDefaultsService.shared[keyPath: \.filterOrders]

        return raw.flatMap { Order(rawValue: $0) }
    }()

    private var selectedDuration: Duration? = {
        let raw: String? = UserDefaultsService.shared[keyPath: \.filterDurations]

        return raw.flatMap { descript in
            Duration.allCases.first { $0.description == descript }
        }
    }()

    let userDefaults = UserDefaultsService.shared

    var onApply: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    deinit {
        print("filterView 해제")
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

    // 오토 스크롤
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let selCat = selectedCategories,
           let catIdx = categories.firstIndex(of: selCat) {
            let ip = IndexPath(item: catIdx, section: 0)
            filterCategoryCollectionView.selectItem(
                at: ip, animated: false, scrollPosition: []
            )
            filterCategoryCollectionView.scrollToItem(
                at: ip, at: .centeredHorizontally, animated: true
            )
        }

        if let selOrd = selectedOrder,
           let ordIdx = orders.firstIndex(of: selOrd) {
            let ip = IndexPath(item: ordIdx, section: 0)
            filterOrderCollectionView.selectItem(
                at: ip, animated: false, scrollPosition: []
            )
            filterOrderCollectionView.scrollToItem(
                at: ip, at: .centeredHorizontally, animated: true
            )
        }

        if let selDur = selectedDuration,
           let durIdx = durations.firstIndex(of: selDur) {
            let ip = IndexPath(item: durIdx, section: 0)
            filterVideoDurationCollectionView.selectItem(
                at: ip, animated: false, scrollPosition: []
            )
            filterVideoDurationCollectionView.scrollToItem(
                at: ip, at: .centeredHorizontally, animated: true
            )
        }
    }

    @IBAction func applyButtonTapped(_ sender: UIButton) {
        if selectedCategories != nil {
            userDefaults.filterCategories = selectedCategories.map { $0.rawValue }
        } else {
            userDefaults.clear(forKey: \.filterCategories)
        }

        if selectedOrder != nil {
            userDefaults.filterOrders = selectedOrder.map { $0.rawValue }
        } else {
            userDefaults.clear(forKey: \.filterOrders)
        }

        if selectedDuration != nil {
            userDefaults.filterDurations = selectedDuration.map { $0.description }
        } else {
            userDefaults.clear(forKey: \.filterDurations)
        }

        // 콜백 메서드
        onApply?()
        dismiss(animated: true)
    }

    @IBAction func initButtonTapped(_ sender: UIButton) {
        userDefaults.clear(forKey: \.filterCategories)
        userDefaults.clear(forKey: \.filterOrders)
        userDefaults.clear(forKey: \.filterDurations)

        selectedCategories = nil
        selectedOrder = nil
        selectedDuration = nil

        filterCategoryCollectionView.reloadData()
        filterOrderCollectionView.reloadData()
        filterVideoDurationCollectionView.reloadData()

        onApply?()
        dismiss(animated: true)
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

extension SearchFilterViewController: UICollectionViewDataSource {
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
            cell.categoryLabel.text = target.displayName

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

            if selectedCategories == category {
                selectedCategories = nil
                collectionView.deselectItem(at: indexPath, animated: true)
            } else {
                if let prev = selectedCategories,
                   let prevIndex = categories.firstIndex(of: prev) {
                    collectionView.deselectItem(at: IndexPath(item: prevIndex, section: 0), animated: false)
                }

                selectedCategories = category
            }

            // 날짜: 단일 선택
        case filterOrderCollectionView:
            let order = orders[indexPath.item]

            if selectedOrder == order {
                selectedOrder = nil
                collectionView.deselectItem(at: indexPath, animated: true)
            } else {
                if let prev = selectedOrder,
                   let prevIndex = orders.firstIndex(of: prev) {
                    collectionView.deselectItem(at: IndexPath(item: prevIndex, section: 0), animated: false)
                }
                selectedOrder = order
            }

            // 길이: 단일 선택
        case filterVideoDurationCollectionView:
            let duration = durations[indexPath.item]

            if selectedDuration == duration {
                selectedDuration = nil
                collectionView.deselectItem(at: indexPath, animated: true)
            } else {
                if let prev = selectedDuration,
                   let prevIndex = durations.firstIndex(of: prev) {
                    collectionView.deselectItem(at: IndexPath(item: prevIndex, section: 0), animated: false)
                }
                selectedDuration = duration
            }

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


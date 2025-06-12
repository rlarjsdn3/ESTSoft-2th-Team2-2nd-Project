//
//  SearchViewController.swift
//  Media
//
//  Created by Jaehun Kim on 6/8/25.
//

import UIKit

final class SearchViewController: StoryboardViewController, NavigationBarDelegate {
    @IBOutlet weak var searchTableView: UITableView!
    @IBOutlet weak var navigationBar: NavigationBar!
    @IBOutlet weak var placeholderImageView: UIImageView!

    var recordManager = SearchRecordManager()
    private var records: [SearchRecordEntity] = []
    private let userDefaults = UserDefaultsService.shared

    private var selectedCategories: Category? = {
        let raw: String? = UserDefaultsService.shared[keyPath: \.filterCategories]

        return raw.flatMap { Category(rawValue: $0) }
    }()

    private var selectedOrder: Order? = {
        let raw: String? = UserDefaultsService.shared[keyPath: \.filterOrders]

        return raw.flatMap { Order(rawValue: $0) }
    }()

    private lazy var selectedDuration: Duration? = {
        let raw: String? = UserDefaultsService.shared[keyPath: \.filterDurations]

        return raw.flatMap { descript in
            Duration.allCases.first { $0.description == descript }
        }
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        loadRecentSearches()
    }

    override func setupHierachy() {
        configureSearchTableView()
        configureSearchBar()

    }

    override func setupAttributes() {
        self.view.backgroundColor = UIColor.background
        self.searchTableView.backgroundColor = .clear
        changeStateOfFilterButton()
    }

    //검색 기록 테이블뷰 등록
    private func configureSearchTableView() {
        searchTableView.delegate = self
        searchTableView.dataSource = self
        searchTableView.register(
            UINib(nibName: SearchTableViewCell.id, bundle: nil),
            forCellReuseIdentifier: SearchTableViewCell.id)
    }

    // 네비게이션 바 기본 설정
    private func configureSearchBar() {
        self.navigationController?.isNavigationBarHidden = true
        navigationBar.searchBar.delegate = self
        navigationBar.searchBar.returnKeyType = .search
        navigationBar.searchBar.searchTextField.enablesReturnKeyAutomatically = true
        navigationBar.delegate = self
        navigationBar.configure(
            title: "검색",
            leftIcon: UIImage(systemName: "arrow.left"),
            rightIcon: UIImage(systemName: "slider.horizontal.3"),
            isSearchMode: true
        )
    }

    // 필터가 하나라도 켜져 있으면 filterButton 색변경
    private func changeStateOfFilterButton() {
        if selectedCategories != nil || selectedOrder != nil || selectedDuration != nil {
            navigationBar.rightButton.tintColor = .red
        } else {
            navigationBar.rightButton.tintColor = .label
        }
    }

    // 검색 기록 로드
    private func loadRecentSearches() {
        records = (try? recordManager.fetchRecent(limit: 20)) ?? []
        if !records.isEmpty {
            placeholderImageView.isHidden = true
        }
        searchTableView.reloadData()
    }

    //navigationBarItem Tap Event
    func navigationBarDidTapLeft(_ navBar: NavigationBar) {
        navigationController?.popViewController(animated: true)
    }

    func navigationBarDidTapRight(_ navBar: NavigationBar) {
        showSheet()
    }

    // 서치 필터 뷰 present
    func showSheet() {
        let storyboard = UIStoryboard(name: "SearchFilterViewController", bundle: nil)
        let vc = storyboard.instantiateViewController(
            identifier: "SearchFilterViewController"
        ) as! SearchFilterViewController

        // 콜백
        vc.onApply = {
            Toast.makeToast("필터가 적용되었습니다.", systemName: "slider.horizontal.3").present()
            self.reloadSavedFilters()
            self.changeStateOfFilterButton()
        }

        vc.modalPresentationStyle = .pageSheet
        if let sheet = vc.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.selectedDetentIdentifier = .medium

            //디밍: modal이 medium/large 상관 없이 반투명 처리
            sheet.largestUndimmedDetentIdentifier = nil
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            sheet.prefersEdgeAttachedInCompactHeight = true
            sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 20
            sheet.delegate = vc
        }

        present(vc, animated: true)
    }

    // 실시간 필터 색 반영하기 위한 userDefault 리로드
    func reloadSavedFilters() {
            // 1) 카테고리
        if let rawCat: String = userDefaults[keyPath: \.filterCategories],
               let cat = Category(rawValue: rawCat) {
                selectedCategories = cat
            } else {
                selectedCategories = nil
            }

            // 2) 정렬
        if let rawOrd: String = userDefaults[keyPath: \.filterOrders],
               let ord = Order(rawValue: rawOrd) {
                selectedOrder = ord
            } else {
                selectedOrder = nil
            }

            // 3) 길이
        if let rawDur: String = userDefaults[keyPath: \.filterDurations],
               let dur = Duration.allCases.first(where: { $0.description == rawDur }) {
                selectedDuration = dur
            } else {
                selectedDuration = nil
            }
        }
}

extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return records.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SearchTableViewCell.id, for: indexPath) as! SearchTableViewCell
        let target = records[indexPath.row]
        cell.searchLabel.text = target.query

        return cell
    }
}

extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let target = records[indexPath.row]

        let storyboard = UIStoryboard(name: "SearchResultViewController", bundle: nil)
        if let searchResultVC = storyboard.instantiateViewController(withIdentifier: "SearchResultViewController") as? SearchResultViewController {
            searchResultVC.keyword = target.query!
            // 검색 기록 저장
            do {
                try recordManager.save(query: target.query!)
            } catch {
                print("Search Record save error:", error)
            }

            loadRecentSearches()
            navigationController?.pushViewController(searchResultVC, animated: true)
        }
    }

    // 스와이핑 삭제
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
    -> UISwipeActionsConfiguration?
    {
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { [weak self] _, _, completion in
            guard let self = self else { return }

            self.showDeleteAlert(
                "정말 삭제하시겠습니까?",
                message: "이 검색 기록은 복구할 수 없습니다.",
                onConfirm: { _ in
                    // 데이터 삭제
                    let record = self.records[indexPath.row]
                    do {
                        try self.recordManager.delete(record: record)

                        self.records.remove(at: indexPath.row)
                        tableView.deleteRows(at: [indexPath], with: .automatic)
                        completion(true)
                    } catch {
                        print("삭제 실패:", error)
                        completion(false)
                    }
                },
                onCancel: { _ in
                    completion(false)
                }
            )
        }

        deleteAction.image = UIImage(systemName: "trash")
        deleteAction.image?.withTintColor(UIColor.white)
        deleteAction.backgroundColor = .systemRed

        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}

extension SearchViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let keyword = searchBar.text, !keyword.isEmpty else { return }

        // 키보드 내리기
        searchBar.resignFirstResponder()

        // 검색 기록 저장
        do {
            try recordManager.save(query: keyword)
        } catch {
            print("Search Record save error:", error)
        }

        loadRecentSearches()

        let storyboard = UIStoryboard(name: "SearchResultViewController", bundle: nil)
        if let searchResultVC = storyboard.instantiateViewController(
            identifier: "SearchResultViewController"
        ) as? SearchResultViewController {
            // 검색어 전달
            searchResultVC.keyword = keyword
            navigationController?.pushViewController(searchResultVC, animated: true)
        }
    }
}

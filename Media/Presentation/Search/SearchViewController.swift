//
//  SearchViewController.swift
//  Media
//
//  Created by 백현진 on 6/8/25.
//

import UIKit

final class SearchViewController: StoryboardViewController {
    @IBOutlet weak var searchTableView: UITableView!
    @IBOutlet weak var navigationBar: NavigationBar!
    @IBOutlet weak var contentUnavailableView: ContentUnavailableView!
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

    private var selectedDuration: Duration? = {
        let raw: String? = UserDefaultsService.shared[keyPath: \.filterDurations]

        return raw.flatMap { descript in
            Duration.allCases.first { $0.description == descript }
        }
    }()

    private var dimmingView: UIView?

    //필터 갯수 표현 라벨
    private lazy var filterLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .systemRed
        label.textColor = .white
        label.font = .systemFont(ofSize: 10, weight: .bold)
        label.textAlignment = .center
        label.layer.masksToBounds = true
        label.isHidden = true
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setKeyBoardDismissGesture()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        loadRecentSearches()
        reloadSavedFilters()
		changeStateOfFilterButton()
    }

    override func setupHierachy() {
        configureSearchTableView()
        configureSearchBar()
        navigationBar.searchBar.becomeFirstResponder()
        NSLayoutConstraint.activate([
            filterLabel.trailingAnchor.constraint(equalTo: navigationBar.rightButton.trailingAnchor, constant: 5),
            filterLabel.topAnchor.constraint(equalTo: navigationBar.rightButton.topAnchor, constant: -10),
            filterLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 15),
            filterLabel.heightAnchor.constraint(equalToConstant: 15)
        ])

        view.layoutIfNeeded()
        filterLabel.layer.cornerRadius = filterLabel.bounds.height / 2
    }

    override func setupAttributes() {
        self.view.backgroundColor = UIColor.background
        self.searchTableView.backgroundColor = .clear
        contentUnavailableView.alpha = 0.0
        changeStateOfFilterButton()
    }


    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        filterLabel.layer.cornerRadius =
        filterLabel.bounds.size.height / 2
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
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
        navigationBar.rightButton.addSubview(filterLabel)
    }

    // 키보드 dismiss
    private func setKeyBoardDismissGesture() {
        let tap = UITapGestureRecognizer(
            target: self,
            action: #selector(dismissKeyboard)
        )
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    // 필터가 하나라도 켜져 있으면 filterButton색, filterLabel 활성화
    private func changeStateOfFilterButton() {
        let count = (selectedCategories != nil ? 1 : 0) + (selectedOrder != nil ? 1 : 0) + (selectedDuration != nil ? 1 : 0)
        if count > 0 {
            navigationBar.rightButton.tintColor = .red
            filterLabel.isHidden = false
            filterLabel.text = "\(count)"
        } else {
            filterLabel.isHidden = true
            navigationBar.rightButton.tintColor = .label
        }
    }

    // 검색 기록 로드
    private func loadRecentSearches() {
        records = (try? recordManager.fetchRecent(limit: 20)) ?? []
        if !records.isEmpty {
            contentUnavailableView.alpha = 0.0
        } else {
            contentUnavailableView.alpha = 1.0
            contentUnavailableView.imageResource = .searchDefault

        }
        searchTableView.reloadData()
    }

    // 서치 필터 뷰 present
    private func showSheet() {
        let storyboard = UIStoryboard(name: "SearchFilterViewController", bundle: nil)
        let vc = storyboard.instantiateViewController(
            identifier: "SearchFilterViewController"
        ) as! SearchFilterViewController

        // 콜백
        vc.onApply = {
            Toast.makeToast("Filter has been applied.", systemName: "slider.horizontal.3").present()
            self.reloadSavedFilters()
            self.changeStateOfFilterButton()
            self.dimmingView?.removeFromSuperview()
        }

        vc.onDismiss = {
            self.dimmingView?.removeFromSuperview()
        }

        vc.modalPresentationStyle = .pageSheet
        if let sheet = vc.sheetPresentationController {
            sheet.detents = [
                .medium(),
                .custom{ context in
                    0.8 * context.maximumDetentValue
                }
            ]
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

        let dim = UIView(frame: view.bounds)
        dim.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        dim.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(dim)
        self.dimmingView = dim

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

        let trimmed = target.query?.trimmingCharacters(in: .whitespacesAndNewlines)

        let storyboard = UIStoryboard(name: "SearchResultViewController", bundle: nil)
        if let searchResultVC = storyboard.instantiateViewController(withIdentifier: "SearchResultViewController") as? SearchResultViewController {
            searchResultVC.keyword = trimmed
            // 검색 기록 저장
            do {
                try recordManager.save(query: trimmed!)
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
                "Delete Keyword",
                message: "This keyword cannot be recovered..",
                onConfirm: { _ in
                    // 데이터 삭제
                    let record = self.records[indexPath.row]
                    do {
                        try self.recordManager.delete(record: record)

                        self.records.remove(at: indexPath.row)
                        tableView.deleteRows(at: [indexPath], with: .automatic)

                        if !self.records.isEmpty {
                            self.contentUnavailableView.alpha = 0.0
                        } else {
                            self.contentUnavailableView.alpha = 1.0
                            self.contentUnavailableView.imageResource = .searchDefault
                        }

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

        let trimmed = keyword.trimmingCharacters(in: .whitespacesAndNewlines)

        // 검색 기록 저장
        do {
            try recordManager.save(query: trimmed)
        } catch {
            print("Search Record save error:", error)
        }

        loadRecentSearches()

        let storyboard = UIStoryboard(name: "SearchResultViewController", bundle: nil)
        if let searchResultVC = storyboard.instantiateViewController(
            identifier: "SearchResultViewController"
        ) as? SearchResultViewController {
            // 검색어 전달
            searchResultVC.keyword = trimmed
            navigationController?.pushViewController(searchResultVC, animated: true)
        }
    }
}

extension SearchViewController: NavigationBarDelegate {
    func navigationBarDidTapLeft(_ navBar: NavigationBar) {
        navigationController?.popViewController(animated: true)
    }

    func navigationBarDidTapRight(_ navBar: NavigationBar) {
        showSheet()
    }
}


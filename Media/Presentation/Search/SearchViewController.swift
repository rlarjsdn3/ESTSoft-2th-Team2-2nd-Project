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

    var recordManager = SearchRecordManager()
    private var records: [SearchRecordEntity] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        loadRecentSearches()
        navigationBar.delegate = self
        navigationBar.configure(
              title: "검색",
              leftIcon: UIImage(systemName: "arrow.left"),
              rightIcon: UIImage(systemName: "slider.horizontal.3"),
              isSearchMode: true
        )
    }

    override func setupHierachy() {
        configureSearchTableView()
        self.navigationController?.isNavigationBarHidden = true
    }

    override func setupAttributes() {
    }

    //검색 기록 테이블뷰 등록
    private func configureSearchTableView() {
        searchTableView.delegate = self
        searchTableView.dataSource = self
        searchTableView.register(
            UINib(nibName: SearchTableViewCell.id, bundle: nil),
            forCellReuseIdentifier: SearchTableViewCell.id)
    }

    // 검색 기록 로드
    private func loadRecentSearches() {
        records = (try? recordManager.fetchRecent(limit: 20)) ?? []
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
        let storyboard = UIStoryboard(name: "SearchResultViewController", bundle: nil)
        if let searchResultVC = storyboard.instantiateViewController(withIdentifier: "SearchResultViewController") as? SearchResultViewController {
            navigationController?.pushViewController(searchResultVC, animated: true)
        }
    }
}

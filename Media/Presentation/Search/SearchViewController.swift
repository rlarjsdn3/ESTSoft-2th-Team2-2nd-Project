//
//  SearchViewController.swift
//  Media
//
//  Created by Jaehun Kim on 6/8/25.
//

import UIKit

final class SearchViewController: StoryboardViewController {
    @IBOutlet weak var searchTableView: UITableView!

    var recordManager = SearchRecordManager()
    private var records: [SearchRecordEntity] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        loadRecentSearches()
    }

    override func setupHierachy() {
        configureSearchTableView()
    }

    override func setupAttributes() {
        searchTableView.backgroundColor = .yellow
    }

    private func configureSearchTableView() {
        searchTableView.delegate = self
        searchTableView.dataSource = self
        searchTableView.register(
            UINib(nibName: SearchTableViewCell.id, bundle: nil),
            forCellReuseIdentifier: SearchTableViewCell.id)
    }

    private func loadRecentSearches() {
        records = (try? recordManager.fetchRecent(limit: 20)) ?? []
        searchTableView.reloadData()
    }

    @IBAction func showSheet(_ sender: Any) {
        showSheet()
    }

    func showSheet() {
        let storyboard = UIStoryboard(name: "SearchFilterViewController", bundle: nil)
        let vc = storyboard.instantiateViewController(
            identifier: "SearchFilterViewController"
        ) as! SearchFilterViewController

        vc.modalPresentationStyle = .pageSheet

        if let sheet = vc.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.selectedDetentIdentifier = .medium
            sheet.largestUndimmedDetentIdentifier = .large
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            sheet.prefersEdgeAttachedInCompactHeight = true
            sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 20
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

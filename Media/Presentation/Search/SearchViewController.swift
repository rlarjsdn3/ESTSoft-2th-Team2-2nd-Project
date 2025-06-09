//
//  SearchViewController.swift
//  Media
//
//  Created by Jaehun Kim on 6/8/25.
//

import UIKit

final class SearchViewController: StoryboardViewController {
    @IBOutlet weak var searchTableView: UITableView!

    private let recordManager = SearchRecordManager()
    private var records: [SearchRecordEntity] = []

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func setupHierachy() {
        configureSearchTableView()
        loadRecentSearches()
    }

    override func setupAttributes() {
        searchTableView.backgroundColor = .yellow
    }

    private func configureSearchTableView() {
        searchTableView.delegate = self
        searchTableView.dataSource = self
    }

    private func loadRecentSearches() {
        records = (try? recordManager.fetchRecent(limit: 20)) ?? []
        searchTableView.reloadData()
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

}

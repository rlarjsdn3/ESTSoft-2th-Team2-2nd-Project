//
//  SearchResultViewController.swift
//  Media
//
//  Created by 백현진 on 6/9/25.
//

import UIKit

final class SearchResultViewController: StoryboardViewController, NavigationBarDelegate {
    @IBOutlet weak var navigationBar: NavigationBar!

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationBar.delegate = self
        navigationBar.configure(
              title: "검색",
              leftIcon: UIImage(systemName: "arrow.left"),
              rightIcon: UIImage(systemName: "slider.horizontal.3"),
              isSearchMode: true
        )
    }

    override func setupHierachy() {
        self.navigationController?.isNavigationBarHidden = true
    }

    override func setupAttributes() {
    }

    //naviationBar event
    func navigationBarDidTapLeft(_ navBar: NavigationBar) {
        navigationController?.popViewController(animated: true)
    }

    func navigationBarDidTapRight(_ navBar: NavigationBar) {
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

//
//  HomeViewController.swift
//  Media
//
//  Created by 김건우 on 6/5/25.
//

import UIKit

final class HomeViewController: StoryboardViewController {

    let service = DefaultDataTransferService()

    override func viewDidLoad() {
        super.viewDidLoad()

        service.request(APIEndpoints.pixabay(query: "flower yellow", perPage: 3)) { result in
            switch result {
            case .success(let value):
                print(value.hits.count)
            case .failure(let error):
                print(error)
            }
        }
    }
}


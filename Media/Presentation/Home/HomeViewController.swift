//
//  HomeViewController.swift
//  Media
//
//  Created by 김건우 on 6/5/25.
//

import UIKit

final class HomeViewController: StoryboardViewController {

    let dataTransferService: any DataTransferService = DefaultDataTransferService()

    override func viewDidLoad() {
        super.viewDidLoad()

        fetchMedia()
    }

    func fetchMedia() {
        dataTransferService.request(APIEndpoints.media()) { result in
            switch result {
            case .success(let media):
                print(media)
            case .failure(let error):
                print(error)
            }
        }
    }
}


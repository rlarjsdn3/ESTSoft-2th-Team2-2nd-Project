//
//  APIEndpoints.swift
//  News
//
//  Created by 김건우 on 5/31/25.
//

import Foundation

struct APIEndpoints {

    struct Media: Decodable {
        var title: String
    }

    static func media() -> Endpoint<Media> {
        return Endpoint<Media>(path: "/media", mock: Media(title: "Media"))
    }
}

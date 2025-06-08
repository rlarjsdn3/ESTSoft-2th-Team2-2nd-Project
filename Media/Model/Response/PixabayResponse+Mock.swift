//
//  PixabayResponse+Mock.swift
//  Media
//
//  Created by 김건우 on 6/8/25.
//

import Foundation

extension PixabayResponse {

    static var mock: PixabayResponse = {
        guard let url = Bundle.main.url(forResource: "PixabayResponse", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            fatalError("can not load JSON file")
        }

        do {
            let decoder = JSONDecoder()
            return try decoder.decode(PixabayResponse.self, from: data)
        } catch {
            fatalError("can not decode JSON file: \(error)")
        }
    }()
}

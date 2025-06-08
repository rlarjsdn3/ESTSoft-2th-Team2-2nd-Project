//
//  APIEndpoints.swift
//  News
//
//  Created by 김건우 on 5/31/25.
//

import Foundation

struct APIEndpoints {
    
    /// Pixabay 영상 검색 API를 위한 Endpoint를 생성합니다.
    /// - Parameters:
    ///   - query: 검색할 키워드입니다. (예: "nature", "people")
    ///   - category: 필터링할 카테고리입니다. 지정하지 않으면 전체 카테고리에서 검색됩니다.
    ///   - order: 정렬 기준입니다. 기본값은 인기순(.popular)입니다.
    ///   - page: 가져올 페이지 번호입니다. 기본값은 1입니다.
    ///   - perPage: 한 페이지당 가져올 결과 수입니다. 기본값은 3입니다.
    /// - Returns: `PixabayResponse` 타입을 반환하는 Endpoint 인스턴스
    static func pixabay(
        query: String? = nil,
        category: Category? = nil,
        order: Order = .popular,
        page: Int = 1,
        perPage: Int = 3
    ) -> Endpoint<PixabayResponse> {
        var queryParameters: [String: Any] = [:]
        if let query = query {
            queryParameters["q"] = query
        }
        if let category = category {
            queryParameters["category"] = category.rawValue
        }
        queryParameters["order"] = order.rawValue
        queryParameters["page"] = page
        queryParameters["per_page"] = perPage

        return Endpoint(
            path: "/videos/",
            method: .get,
            queryParameters: queryParameters,
            mock: PixabayResponse.mock
        )
    }
    
    /// 썸네일 이미지를 다운로드하기 위한 Endpoint를 생성합니다.
    /// - Parameter url: 이미지 파일의 절대 URL
    /// - Returns: 이미지 데이터를 반환하는 Endpoint 인스턴스
    static func thumbnail(url: URL) -> Endpoint<Data> {
        return Endpoint(
            baseUrl: url.absoluteString,
            responseDecoder: RawDataResponseDecoder()
        )
    }
}


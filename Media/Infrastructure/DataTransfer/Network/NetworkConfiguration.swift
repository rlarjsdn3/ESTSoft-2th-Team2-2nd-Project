//
//  NetworkConfiguration.swift
//  DataTransferService
//
//  Created by 김건우 on 5/31/25.
//

import Foundation

/// 네트워크 요청에 공통적으로 사용되는 설정 정보를 정의하는 프로토콜입니다.
protocol NetworkConfigurable {
    /// 네트워크 요청의 기본 URL입니다.
    var baseUrl: String { get }
    /// 모든 요청에 공통적으로 포함될 HTTP 헤더입니다.
    var headers: [String: String] { get }
    /// 모든 요청에 기본적으로 포함될 쿼리 파라미터입니다.
    var queryParameters: [String: String] { get }
}

struct DefaultNetworkConfiguration: NetworkConfigurable {

    let baseUrl: String = "https://newsdata.io/api/1"

    let headers: [String : String] = ["X-ACCESS-KEY": "pub_5b56753106094df6b0c4c2c2667f205b"]

    let queryParameters: [String : String] = [:]
}

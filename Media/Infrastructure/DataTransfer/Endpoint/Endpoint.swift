//
//  Endpoint.swift
//  DataTransferService
//
//  Created by 김건우 on 5/30/25.
//

import Foundation

/// HTTP 요청에서 사용되는 메서드 타입을 정의한 열거형입니다.
enum HttpMethodType: String {
    /// 서버로부터 리소스를 조회할 때 사용하는 GET 메서드입니다.
    case get = "GET"
    /// 서버에 데이터를 생성할 때 사용하는 POST 메서드입니다.
    case post = "POST"
    /// 서버의 리소스를 수정할 때 사용하는 PUT 메서드입니다.
    case put = "PUT"
}

struct Endpoint<R>: ResponseRequestable {

    typealias Response = R

    let baseUrl: String?
    let path: String
    let method: HttpMethodType
    let headerParameters: [String : String]
    let queryParametersEncodable: (any Encodable)?
    let queryParameters: [String : Any]
    let bodyParametersEncodable: (any Encodable)?
    let bodyParameters: [String : Any]
    let bodyEncoder: any BodyEncoder
    let responseDecoder: any ResponseDecoder
    let mock: Response?

    /// Endpoint 객체를 초기화합니다.
    ///
    /// 빌드 스킴이 `DEBUG`일 경우, `mock`에 값이 설정되어 있다면 실제 네트워크 요청을 수행하지 않고 해당 mock 데이터를 반환합니다.
    /// `mock`이 설정되어 있지 않은 경우에는 빌드 스킴과 관계없이 실제 네트워크 요청이 이루어집니다.
    ///
    /// - Parameters:
    ///   - baseUrl: 요청할 API의 전체 주소입니다. 전체 요청 URL을 직접 지정할 경우 사용합니다. 이 값이 설정되면 `path`와 쿼리 관련 매개변수는 무시됩니다.
    ///   - path: 요청할 API의 경로입니다. (예: "/books")
    ///   - method: HTTP 요청 메서드입니다. (예: .get, .post)
    ///   - headerParameters: 요청에 포함할 HTTP 헤더 필드입니다.
    ///   - queryParametersEncodable: Encodable 객체를 쿼리 파라미터로 변환할 때 사용됩니다.
    ///   - queryParameters: 딕셔너리 형태의 쿼리 파라미터입니다. `queryParametersEncodable`이 없을 때 사용됩니다.
    ///   - bodyParametersEncodable: Encodable 객체를 HTTP 바디로 변환할 때 사용됩니다.
    ///   - bodyParameters: 딕셔너리 형태의 바디 파라미터입니다. `bodyParametersEncodable`이 없을 때 사용됩니다.
    ///   - bodyEncoder: HTTP 바디 파라미터 인코딩에 사용할 인코더입니다.
    ///   - responseDecoder: 응답 데이터를 디코딩할 때 사용할 디코더입니다.
    ///   - mock: `DEBUG` 환경에서 네트워크 요청 대신 사용할 목(mock) 응답 데이터입니다.
    init(
        baseUrl: String? = nil,
        path: String = "",
        method: HttpMethodType = .get,
        headerParameters: [String : String] = [:],
        queryParametersEncodable: (any Encodable)? = nil,
        queryParameters: [String : Any] = [:],
        bodyParametersEncodable: (any Encodable)? = nil,
        bodyParameters: [String : Any] = [:],
        bodyEncoder: any BodyEncoder = DefaultBodyEncoder(),
        responseDecoder: any ResponseDecoder = DefaultResponseDecoder(),
        mock: Response? = nil
    ) {
        self.baseUrl = baseUrl
        self.path = path
        self.method = method
        self.headerParameters = headerParameters
        self.queryParametersEncodable = queryParametersEncodable
        self.queryParameters = queryParameters
        self.bodyParametersEncodable = bodyParametersEncodable
        self.bodyParameters = bodyParameters
        self.bodyEncoder = bodyEncoder
        self.responseDecoder = responseDecoder
        self.mock = mock
    }
}

//
//  Requestable.swift
//  DataTransferService
//
//  Created by 김건우 on 5/31/25.
//

import Foundation

/// URLRequest를 생성하는 과정에서 발생할 수 있는 오류를 정의한 열거형입니다.
enum RequestGenerationError: Error {
    /// URLComponents 구성에 실패했을 때 발생하는 오류입니다.
    case components
}

/// 네트워크 요청에 필요한 기본 정보를 정의하는 프로토콜입니다.
protocol Requestable {
    ///
    var baseUrl: String? { get }
    
    /// API 요청의 엔드포인트 경로입니다.
    var path: String { get }

    /// 요청에 사용될 HTTP 메서드입니다.
    var method: HttpMethodType { get }

    /// 요청에 포함될 HTTP 헤더입니다.
    var headerParameters: [String: String] { get }

    /// 인코딩 가능한 쿼리 파라미터입니다. 값이 있으면 `queryParameters`는 무시됩니다.
    var queryParametersEncodable: (any Encodable)? { get }

    /// 사전 형태의 쿼리 파라미터입니다. `queryParametersEncodable`이 없을 경우에 사용됩니다.
    var queryParameters: [String: Any] { get }

    /// 인코딩 가능한 바디 파라미터입니다. 값이 있으면 `bodyParameters`는 무시됩니다.
    var bodyParametersEncodable: (any Encodable)? { get }

    /// 사전 형태의 바디 파라미터입니다. `bodyParametersEncodable`이 없을 경우에 사용됩니다.
    var bodyParameters: [String: Any] { get }

    /// 바디 파라미터를 인코딩할 때 사용되는 인코더입니다.
    var bodyEncoder: (any BodyEncoder) { get }
}

extension Requestable {

    /// 네트워크 설정 정보를 기반으로 최종 URL을 생성합니다.
    ///
    /// - Parameter config: 기본 URL, 공통 쿼리 파라미터 등을 포함하는 네트워크 설정 객체입니다.
    /// - Returns: 최종적으로 생성된 요청용 URL 객체입니다.
    /// - Throws: URLComponents 생성 실패 또는 유효하지 않은 URL 구성 시 오류를 던집니다.
    func url(with config: any NetworkConfigurable) throws -> URL {

        let baseUrl = self.baseUrl ?? {
            let url = config.baseUrl.hasSuffix("/")
            ? config.baseUrl
            : config.baseUrl + "/"
            return url.appending(path)
        }()

        guard var urlComponents = URLComponents(
            string: baseUrl
        ) else { throw RequestGenerationError.components }
        var queryItems: [URLQueryItem] = []

        let queryParameters = try queryParametersEncodable?.toDictionary() ?? queryParameters
        queryParameters.forEach {
            queryItems.append(URLQueryItem(name: $0.key, value: "\($0.value)"))
        }
        config.queryParameters.forEach {
            queryItems.append(URLQueryItem(name: $0.key, value: $0.value))
        }

        urlComponents.queryItems = queryItems
        guard let url = urlComponents.url else { throw RequestGenerationError.components }
        return url
    }

    /// 네트워크 설정과 현재 엔드포인트 정보를 바탕으로 `URLRequest` 객체를 생성합니다.
    ///
    /// - Parameter config: 기본 URL, 공통 헤더 등을 포함하는 네트워크 설정 객체입니다.
    /// - Returns: 구성된 `URLRequest` 객체입니다.
    /// - Throws: URL 생성 또는 바디 파라미터 디코딩 중 오류가 발생할 경우 예외를 던집니다.
    func urlRequest(with config: any NetworkConfigurable) throws -> URLRequest {

        let url = try self.url(with: config)
        var urlRequest = URLRequest(url: url)
        var allHeaders = config.headers
        headerParameters.forEach {
            allHeaders.updateValue($0.value, forKey: $0.key)
        }

        let bodyParameters = try bodyParametersEncodable?.toDictionary() ?? bodyParameters
        if !bodyParameters.isEmpty {
            urlRequest.httpBody = bodyEncoder.encode(bodyParameters)
        }
        urlRequest.httpMethod = method.rawValue
        urlRequest.allHTTPHeaderFields = allHeaders
        return urlRequest
    }
}

/// 응답 디코딩이 필요한 요청을 정의하는 프로토콜입니다.
protocol ResponseRequestable: Requestable {

    /// API 요청에 대한 응답으로 디코딩될 타입입니다.
    associatedtype Response

    /// 수신된 데이터를 지정된 타입으로 디코딩하기 위한 디코더입니다.
    var responseDecoder: (any ResponseDecoder) { get }

    /// `Debug` 모드에서 네트워크 통신을 하는 대신 넘겨줄 목 데이터입니다.
    var mock: Response? { get }
}





fileprivate extension Encodable {

    func toDictionary() throws -> [String: Any]? {
        let data = try JSONEncoder().encode(self)
        let jsonData = try JSONSerialization.jsonObject(with: data)
        return jsonData as? [String: Any]
    }
}

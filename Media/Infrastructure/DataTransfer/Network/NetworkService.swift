//
//  NetworkService.swift
//  DataTransferService
//
//  Created by 김건우 on 5/30/25.
//

import Foundation

/// 네트워크 요청을 취소할 수 있도록 정의한 프로토콜입니다.
protocol NetworkCancellable {
    /// 네트워크 요청을 취소합니다.
    func cancel()
}

extension URLSessionDataTask: NetworkCancellable { }

extension URLSessionDownloadTask: NetworkCancellable { }


/// 네트워크 요청을 수행하고, 그 결과를 비동기적으로 반환하는 기능을 정의한 프로토콜입니다.
protocol NetworkService {
    /// 네트워크 요청 완료 시 호출되는 결과 처리 핸들러입니다.
    typealias CompletionHandler<T> = (Result<T?, NetworkError>) -> Void

    /// 지정된 엔드포인트를 기반으로 네트워크 요청을 수행합니다.
    /// - Parameters:
    ///   - endpoint: 요청에 필요한 정보를 담고 있는 엔드포인트입니다.
    ///   - completion: 요청 완료 시 호출되는 클로저로, 성공 시 데이터 또는 실패 시 네트워크 에러를 반환합니다.
    /// - Returns: 실행 중인 네트워크 요청을 취소할 수 있는 객체이며, 요청 생성에 실패한 경우 `nil`을 반환합니다.
    func dataTask(
        _ endpoint: any Requestable,
        completion: @escaping CompletionHandler<Data>
    ) -> (any NetworkCancellable)?

    ///
    func download(
        _ endpoint: any Requestable,
        completion: @escaping CompletionHandler<URL>
    ) -> (any NetworkCancellable)?
}

final class DefaultNetworkService {

    /// 네트워크 요청에 사용되는 공통 설정을 담고 있는 객체입니다.
    private let config: any NetworkConfigurable

    /// 실제 URL 요청을 처리하는 세션 매니저입니다.
    private let sessionManager: any NetworkSessionManager

    /// 네트워크 요청 및 응답에 대한 로그를 기록하는 로거입니다.
    private let logger: any NetworkErrorLogger

    /// 네트워크 서비스 객체를 초기화합니다.
    /// - Parameters:
    ///   - config: 요청에 사용될 기본 URL, 헤더, 쿼리 파라미터 등의 설정 정보입니다.
    ///   - sessionManager: URLSession을 통한 실제 요청 처리를 담당하는 객체입니다.
    ///   - logger: 요청, 응답, 에러에 대한 로깅을 담당하는 객체입니다.
    init(
        config: any NetworkConfigurable = DefaultNetworkConfiguration(),
        sessionManager: any NetworkSessionManager = DefaultNetworkSessionManager(),
        logger: any NetworkErrorLogger = DefaultNetworkErrorLogger()
    ) {
        self.config = config
        self.sessionManager = sessionManager
        self.logger = logger
    }

    private func dataTask(
        from request: URLRequest,
        completion: @escaping CompletionHandler<Data>
    ) -> (any NetworkCancellable) {

        let cancellable = sessionManager.dataTask(from: request) { data, response, requestError in

            if let requestError = requestError {
                var error: NetworkError
                if let response = response as? HTTPURLResponse {
                    error = NetworkError.error(statusCode: response.statusCode, data: data)
                } else {
                    error = self.resolveError(requestError)
                }
                self.logger.log(error: requestError)
                completion(.failure(error))
            } else {
                self.logger.log(responseData: data, response: response)
                completion(.success(data))
            }
        }

        logger.log(request: request)

        return cancellable
    }

    private func download(
        from request: URLRequest,
        completion: @escaping CompletionHandler<URL>
    ) -> (any NetworkCancellable) {

        let cancellable = sessionManager.download(from: request) { tempUrl, response, requestError in

            if let requestError = requestError {
                var error: NetworkError
                if let response = response as? HTTPURLResponse {
                    error = NetworkError.error(statusCode: response.statusCode, data: nil)
                } else {
                    error = self.resolveError(requestError)
                }
                self.logger.log(error: requestError)
                completion(.failure(error))
            } else {
                self.logger.log(responseData: nil, response: response)
                completion(.success(tempUrl))
            }
        }

        logger.log(request: request)

        return cancellable
    }

    /// URLSession에서 발생한 에러를 내부에서 정의한 `NetworkError` 타입으로 변환합니다.
    /// - Parameter error: URLSession에서 발생한 에러 객체입니다.
    /// - Returns: `NetworkError` 열거형 값입니다.
    private func resolveError(_ error: Error) -> NetworkError {
        let code = URLError.Code(rawValue: (error as NSError).code)
        switch code {
        case .notConnectedToInternet: return .notConnected
        case .cancelled: return .cancelled
        default: return .generic(error)
        }
    }
}

extension DefaultNetworkService: NetworkService {

    func dataTask(
        _ endpoint: any Requestable,
        completion: @escaping CompletionHandler<Data>
    ) -> (any NetworkCancellable)? {
        do {
            let request = try endpoint.urlRequest(with: config)
            return dataTask(from: request, completion: completion)
        } catch {
            completion(.failure(NetworkError.urlGeneration))
            return nil
        }
    }

    func download(
        _ endpoint: any Requestable,
        completion: @escaping CompletionHandler<URL>
    ) -> (any NetworkCancellable)? {
        do {
            let request = try endpoint.urlRequest(with: config)
            return download(from: request, completion: completion)
        } catch {
            completion(.failure(NetworkError.urlGeneration))
            return nil
        }
    }
}

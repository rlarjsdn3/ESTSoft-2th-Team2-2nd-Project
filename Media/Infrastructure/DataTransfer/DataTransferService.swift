//
//  DataTransferService.swift
//  DataTransferService
//
//  Created by 김건우 on 5/30/25.
//

import Foundation

/// 비동기 작업을 실행하기 위한 디스패치 큐 추상화 프로토콜입니다.
protocol DataTransferDispatchQueue {

    /// 전달된 클로저를 비동기적으로 실행합니다.
    /// - Parameter block: 실행할 클로저입니다.
    func asyncExecute(_ block: @escaping () -> Void)
}

extension DispatchQueue: DataTransferDispatchQueue {
    func asyncExecute(_ block: @escaping () -> Void) {
        async(execute: block)
    }
}

/// 네트워크 요청을 수행하고, 그 결과를 비동기적으로 반환하는 기능을 정의한 프로토콜입니다.
protocol DataTransferService {

    /// 데이터 전송 결과를 처리하기 위한 클로저 타입입니다.
    typealias CompletionHandler<T> = (Result<T, DataTransferError>) -> Void

    /// 응답 가능한 엔드포인트에 대해 네트워크 요청을 수행하고, 응답 데이터를 디코딩하여 결과를 반환합니다.
    ///
    /// - Parameters:
    ///   - endpoint: 요청에 필요한 URL, HTTP 메서드, 파라미터 및 디코더를 포함하는 엔드포인트입니다.
    ///   - queue: 응답 결과를 전달할 디스패치 큐입니다.
    ///   - completion: 요청 결과를 비동기적으로 처리할 클로저입니다. 성공 시 디코딩된 데이터, 실패 시 `DataTransferError`를 반환합니다.
    /// - Returns: 요청을 취소할 수 있는 객체(`NetworkCancellable`)를 반환하며, URL 생성 실패 등의 경우 `nil`을 반환할 수 있습니다.
    @discardableResult
    func request<E, T>(
        _ endpoint: E,
        on queue: any DataTransferDispatchQueue,
        completion: @escaping CompletionHandler<T>
    ) -> (any NetworkCancellable)? where E: ResponseRequestable, E.Response == T, T: Decodable
    
    /// 응답 가능한 엔드포인트에 대해 네트워크 요청을 수행하고, 응답 데이터를 디코딩하여 결과를 반환합니다.
    ///
    /// - Parameters:
    ///   - endpoint: 요청에 필요한 URL, HTTP 메서드, 파라미터 및 디코더를 포함하는 엔드포인트입니다.
    ///   - queue: 응답 결과를 전달할 디스패치 큐입니다.
    ///   - completion: 요청 결과를 비동기적으로 처리할 클로저입니다. 성공 시 디코딩된 데이터, 실패 시 `DataTransferError`를 반환합니다.
    /// - Returns: 요청을 취소할 수 있는 객체(`NetworkCancellable`)를 반환하며, URL 생성 실패 등의 경우 `nil`을 반환할 수 있습니다.
    @discardableResult
    func request<E, T>(
        _ endpoint: E,
        completion: @escaping CompletionHandler<T>
    ) -> (any NetworkCancellable)? where E: ResponseRequestable, E.Response == T, T: Decodable

    /// 주어진 엔드포인트를 통해 네트워크 요청을 수행하고, 응답 데이터를 디코딩하여 반환합니다.
    ///
    /// - Parameter endpoint: 요청에 필요한 경로, HTTP 메서드, 파라미터 및 디코더를 포함하는 엔드포인트입니다.
    /// - Returns: 디코딩된 응답 데이터
    /// - Throws: URL 생성 실패, 네트워크 오류, 디코딩 실패 등의 경우 오류를 던집니다.
    @discardableResult
    func request<E, T>(
        _ endpoint: E
    ) async throws -> T where E: ResponseRequestable, E.Response == T, T: Decodable
}

final class DefaultDataTransferService {

    /// 네트워크 요청을 수행하는 서비스입니다.
    private let service: any NetworkService

    /// 데이터 전송 중 발생한 오류를 기록하는 로거입니다.
    private let logger: any DataTransferErrorLogger

    /// 데이터 전송 서비스의 인스턴스를 초기화합니다.
    ///
    /// - Parameters:
    ///   - service: 실제 네트워크 통신을 수행할 네트워크 서비스입니다. 기본값은 `DefaultNetworkService`입니다.
    ///   - logger: 오류 로깅을 담당할 로거 객체입니다. 기본값은 `DefaultTransferErrorLogger`입니다.
    init(
        service: any NetworkService = DefaultNetworkService(),
        logger: any DataTransferErrorLogger = DefaultTransferErrorLogger()
    ) {
        self.service = service
        self.logger = logger
    }
}

extension DefaultDataTransferService: DataTransferService {

    @discardableResult
    func request<E, T>(
        _ endpoint: E,
        on queue: any DataTransferDispatchQueue = DispatchQueue.main,
        completion: @escaping CompletionHandler<T>
    ) -> (any NetworkCancellable)? where E: ResponseRequestable, T == E.Response, T: Decodable {

        let handleResult: (Result<Data?, NetworkError>) -> Void = { result in
            switch result {
            case .success(let data):
                let decoded: Result<T, DataTransferError> = self.decode(
                    endpoint.responseDecoder,
                    data: data
                )
                queue.asyncExecute { completion(decoded) }
            case .failure(let error):
                self.logger.log(error: error)
                let resolvedError = self.resolve(networkError: error)
                queue.asyncExecute { completion(.failure(resolvedError)) }
            }
        }

        #if DEBUG
        if let mock = endpoint.mock {
            completion(.success(mock))
            return URLSessionDataTask()
        }
        #endif

        return service.dataTask(endpoint, completion: handleResult)
    }

    @discardableResult
    func request<E, T>(
        _ endpoint: E,
        completion: @escaping CompletionHandler<T>
    ) -> (any NetworkCancellable)? where E: ResponseRequestable, T: Decodable, T == E.Response {
        self.request(endpoint, on: DispatchQueue.main, completion: completion)
    }

    func request<E, T>(
        _ endpoint: E
    ) async throws -> T where E: ResponseRequestable, T == E.Response, T: Decodable {
        try await withCheckedThrowingContinuation { continuation in
            self.request(endpoint) { result in
                switch result {
                case .success(let value):
                    continuation.resume(returning: value)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    /// 주어진 디코더를 사용하여 응답 데이터를 디코딩합니다.
    ///
    /// - Parameters:
    ///   - decoder: 응답 데이터를 디코딩할 디코더입니다.
    ///   - data: 서버로부터 수신된 응답 데이터입니다.
    /// - Returns: 디코딩에 성공하면 디코딩된 모델을 포함한 `.success`, 실패하면 `.failure(.parsing)` 또는 `.failure(.noResponse)`를 반환합니다.
    private func decode<T>(
        _ decoder: any ResponseDecoder,
        data: Data?
    ) -> Result<T, DataTransferError> where T: Decodable {
        do {
            guard let data = data else { return .failure(.noResponse) }
            let result: T = try decoder.decode(data)
            return .success(result)
        } catch {
//            self.errorLogger.log(error: error)
            return .failure(.parsing(error))
        }
    }

    private func resolve(networkError: NetworkError) -> DataTransferError {
        return .networkFailiure(networkError)
    }
}

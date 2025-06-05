//
//  NetworkSessionManager.swift
//  DataTransferService
//
//  Created by 김건우 on 5/31/25.
//

import Foundation

/// 네트워크 세션을 통해 URL 요청을 수행하는 역할을 담당합니다.
protocol NetworkSessionManager {
    /// 네트워크 요청 완료 시 호출되는 결과 처리 핸들러입니다.
    typealias CompletionHandler = (Data?, URLResponse?, Error?) -> Void

    /// URL 요청을 수행하고 결과를 비동기적으로 반환합니다.
    /// - Parameters:
    ///   - request: 수행할 URL 요청입니다.
    ///   - completionHandler: 요청 완료 시 호출되는 클로저로, `Data`, `URLResponse`, `Error`를 전달합니다.
    /// - Returns: 실행 중인 네트워크 요청을 취소할 수 있는 `NetworkCancellable` 객체입니다.
    func dataTask(
        from request: URLRequest,
        completionHandler: @escaping CompletionHandler
    ) -> (any NetworkCancellable)
}

final class DefaultNetworkSessionManager: NetworkSessionManager {

    private let session = URLSession.shared

    func dataTask(
        from request: URLRequest,
        completionHandler: @escaping CompletionHandler
    ) -> (any NetworkCancellable) {
        let dataTask = URLSession.shared.dataTask(with: request, completionHandler: completionHandler)
        dataTask.resume()
        return dataTask
    }
}

//
//  NetworkErrorLogger.swift
//  DataTransferService
//
//  Created by 김건우 on 5/31/25.
//

import Foundation

/// 네트워크 요청과 응답, 에러 정보를 기록하는 역할을 담당하는 프로토콜입니다.
protocol NetworkErrorLogger {

    /// 네트워크 요청 중 발생한 에러를 로그로 출력합니다.
    /// - Parameter error: 발생한 에러 객체입니다.
    func log(error: any Error)

    /// 네트워크 응답 데이터를 로그로 출력합니다.
    /// - Parameters:
    ///   - data: 서버로부터 받은 응답 데이터입니다.
    ///   - response: URL 응답 객체입니다.
    func log(responseData data: Data?, response: URLResponse?)

    /// 전송한 네트워크 요청 정보를 로그로 출력합니다.
    /// - Parameter request: 전송된 URL 요청 객체입니다.
    func log(request: URLRequest)
}

struct DefaultNetworkErrorLogger: NetworkErrorLogger {

    func log(error: any Error) {
        print(error)
    }

    func log(responseData data: Data?, response: URLResponse?) {
        guard let data = data else { return }
        if let jsonDict = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            dump(jsonDict)
        }
    }

    func log(request: URLRequest) {
        print(request)
    }
}




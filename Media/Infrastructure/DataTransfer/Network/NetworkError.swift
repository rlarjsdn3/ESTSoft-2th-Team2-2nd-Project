//
//  NetworkError.swift
//  DataTransferService
//
//  Created by 김건우 on 5/31/25.
//

import Foundation

/// 네트워크 요청 도중 발생할 수 있는 오류의 종류를 정의한 열거형입니다.
enum NetworkError: Error {
    /// 사용자가 요청을 취소한 경우입니다.
    case cancelled
    /// 인터넷 연결이 되지 않은 상태에서 요청을 시도한 경우입니다.
    case notConnected
    /// URL 생성 중 오류가 발생한 경우입니다.
    case urlGeneration
    /// 그 외 일반적인 에러가 발생한 경우입니다.
    /// - Parameter error: 발생한 원본 에러 객체입니다.
    case generic(any Error)
    /// HTTP 응답이 실패한 경우입니다.
    /// - Parameters:
    ///   - statusCode: HTTP 상태 코드
    ///   - data: 서버에서 전달된 응답 본문 데이터
    case error(statusCode: Int, data: Data?)
}

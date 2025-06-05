//
//  DataTransferError.swift
//  DataTransferService
//
//  Created by 김건우 on 5/31/25.
//

import Foundation

/// 네트워크 통신 중 발생할 수 있는 오류를 정의한 열거형입니다.
enum DataTransferError: Error {

    /// 서버로부터 응답을 받지 못한 경우입니다.
    case noResponse

    /// 응답 데이터를 디코딩하는 데 실패한 경우입니다.
    /// - Parameter error: 원래 발생한 파싱 오류입니다.
    case parsing(any Error)

    /// 네트워크 계층에서 발생한 오류입니다.
    /// - Parameter error: 네트워크 계층에서 전달된 오류입니다.
    case networkFailiure(NetworkError)
}

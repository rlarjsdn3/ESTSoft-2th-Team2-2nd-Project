//
//  BodyEncoder.swift
//  DataTransferService
//
//  Created by 김건우 on 5/31/25.
//

import Foundation

/// HTTP 요청의 바디 파라미터를 `Data` 형태로 인코딩하는 역할을 정의하는 프로토콜입니다.
protocol BodyEncoder {

    /// 주어진 딕셔너리를 인코딩하여 `Data`로 반환합니다.
    ///
    /// - Parameter parameter: 인코딩할 요청 바디 파라미터입니다.
    /// - Returns: 인코딩된 `Data` 객체 또는 실패 시 `nil`입니다.
    func encode(_ parameter: [String: Any]) -> Data?
}

struct DefaultBodyEncoder: BodyEncoder {
    func encode(_ parameter: [String : Any]) -> Data? {
        return try? JSONSerialization.data(withJSONObject: parameter)
    }
}

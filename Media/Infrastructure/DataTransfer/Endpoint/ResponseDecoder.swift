//
//  ResponseDecoder.swift
//  DataTransferService
//
//  Created by 김건우 on 5/31/25.
//

import Foundation

/// 네트워크 응답 데이터를 디코딩하는 기능을 정의하는 프로토콜입니다.
protocol ResponseDecoder {

    /// 주어진 데이터를 디코딩하여 지정된 타입의 객체로 변환합니다.
    ///
    /// - Parameter data: 디코딩할 원시 `Data`입니다.
    /// - Returns: 디코딩된 객체
    /// - Throws: 디코딩 실패 시 오류를 던집니다.
    func decode<T>(_ data: Data) throws -> T where T: Decodable
}

struct DefaultResponseDecoder: ResponseDecoder {
    private let decoder = {
        let decoder = JSONDecoder()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        decoder.dateDecodingStrategy = .formatted(formatter)
        return decoder
    }()

    func decode<T>(_ data: Data) throws -> T where T: Decodable {
        return try decoder.decode(T.self, from: data)
    }
}

struct RawDataResponseDecoder: ResponseDecoder {
    enum CodingKeys: String, CodingKey {
        case `default` = ""
    }
    
    func decode<T>(_ data: Data) throws -> T {
        if T.self is Data.Type, let data = data as? T {
            return data
        } else {
            let context = DecodingError.Context(
                codingPath: [CodingKeys.default],
                debugDescription: "expected to decode Data"
            )
            throw DecodingError.typeMismatch(T.self, context)
        }
    }
}

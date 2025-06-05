//
//  DataTransferErrorLogger.swift
//  DataTransferService
//
//  Created by 김건우 on 5/31/25.
//

import Foundation

/// 데이터 전송 중 발생한 오류를 기록하는 기능을 정의한 프로토콜입니다.
protocol DataTransferErrorLogger {

    /// 발생한 오류 정보를 기록합니다.
    ///
    /// - Parameter error: 기록할 오류 객체입니다.
    func log(error: any Error)
}

struct DefaultTransferErrorLogger: DataTransferErrorLogger {
    func log(error: any Error) {
        print(error)
    }
}

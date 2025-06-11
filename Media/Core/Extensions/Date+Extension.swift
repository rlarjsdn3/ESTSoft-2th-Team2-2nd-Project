//
//  Date+Extension.swift
//  Media
//
//  Created by 김건우 on 6/10/25.
//

import Foundation

extension Date {

    /// 날짜 포맷을 정의하는 열거형입니다.
    enum Format: String {
        /// 연. 월. 일 형식 (예: 2025. 06. 11)
        case yyyyMMdd = "yyyy. MM. dd"
    }
    
    /// 지정한 문자열 포맷으로 날짜를 문자열로 변환합니다.
    /// - Parameter dateFormat: 날짜 형식 문자열 (예: "yyyy. MM. dd")
    /// - Returns: 변환된 날짜 문자열
    func formatter(_ dateFormat: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        formatter.locale = Locale.current
        formatter.timeZone = TimeZone.current
        return formatter.string(from: self)
    }
    
    /// 지정한 `Date.Format` 타입을 사용하여 날짜를 문자열로 변환합니다.
    /// - Parameter dateFormat: `Date.Format` 열거형 값
    /// - Returns: 변환된 날짜 문자열
    func formatter(_ dateFormat: Date.Format) -> String {
        formatter(dateFormat.rawValue)
    }
}

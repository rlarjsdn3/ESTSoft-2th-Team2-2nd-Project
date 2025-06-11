//
//  Date+Extension.swift
//  Media
//
//  Created by 김건우 on 6/10/25.
//

import Foundation

extension Date {

    enum Format: String {
        ///
        case yyyyMMdd = "yyyy. MM. dd"
    }

    func formatter(_ dateFormat: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        formatter.locale = Locale.current
        formatter.timeZone = TimeZone.current
        return formatter.string(from: self)
    }

    func formatter(_ dateFormat: Date.Format) -> String {
        formatter(dateFormat.rawValue)
    }

}

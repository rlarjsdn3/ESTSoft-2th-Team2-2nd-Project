//
//  String+Extension.swift
//  Media
//
//  Created by 김건우 on 6/12/25.
//

import Foundation

extension String {
    
    /// <#Description#>
    /// - Parameter string: <#string description#>
    /// - Returns: <#description#>
    func split(by string: any StringProtocol) -> [String] {
        self.components(separatedBy: string).map {
            $0.trimmingCharacters(in: .whitespacesAndNewlines)
        }

    }
}

//
//  PlaylistEntity+Extension.swift
//  Media
//
//  Created by 김건우 on 6/11/25.
//

import Foundation

extension PlaylistEntity {
    
    /// <#Description#>
    /// - Parameter name: <#name description#>
    /// - Returns: <#description#>
    static func isExist(_ name: String) -> Bool {
        if let entities: [PlaylistEntity] = try? CoreDataService.shared.fetch() {
            return entities.contains(where: { $0.name == name })
        }
        return false
    }
}

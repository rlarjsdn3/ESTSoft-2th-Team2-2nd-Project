//
//  SearchRecordEntity+Convenience.swift
//  Media
//
//  Created by 백현진 on 6/9/25.
//

import CoreData

extension SearchRecordEntity {
    /// Convenience initializer
    /// - Parameters:
    /// - context: NSManagedObjectContext
    /// - query: 검색어 문자열
    /// - timestamp: 검색 시각 (기본값: 현재 시간)
    convenience init(context: NSManagedObjectContext,
                     query: String,
                     timestamp: Date = Date()) {
        let entity = NSEntityDescription.entity(forEntityName: Self.id,
                                                in: context)!
        self.init(entity: entity, insertInto: context)
        self.query = query
        self.timestamp = timestamp
    }
}

//
//  SearchRecordEntity+CoreDataProperties.swift
//  Media
//
//  Created by 백현진 on 6/9/25.
//
//

import Foundation
import CoreData


extension SearchRecordEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SearchRecordEntity> {
        return NSFetchRequest<SearchRecordEntity>(entityName: "SearchRecordEntity")
    }

    @NSManaged public var query: String?
    @NSManaged public var timestamp: Date?
}

extension SearchRecordEntity : Identifiable {

}

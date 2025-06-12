//
//  TagsEntity+CoreDataProperties.swift
//  Media
//
//  Created by 전광호 on 6/11/25.
//
//

import Foundation
import CoreData


extension TagsEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TagsEntity> {
        return NSFetchRequest<TagsEntity>(entityName: "TagsEntity")
    }

    @NSManaged public var tag: String?

}

extension TagsEntity : Identifiable {

}

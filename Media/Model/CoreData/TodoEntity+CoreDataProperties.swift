//
//  TodoEntity+CoreDataProperties.swift
//  Media
//
//  Created by 김건우 on 6/7/25.
//
//

import Foundation
import CoreData


extension TodoEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TodoEntity> {
        return NSFetchRequest<TodoEntity>(entityName: "TodoEntity")
    }

    @NSManaged public var title: String?

}

extension TodoEntity : Identifiable {

}

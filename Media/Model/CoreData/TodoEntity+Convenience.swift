//
//  TodoEntity+Convenience.swift
//  Media
//
//  Created by 김건우 on 6/7/25.
//

import Foundation
import CoreData

extension TodoEntity {
    
    convenience init(
        title: String,
        insertInto context: NSManagedObjectContext
    ) {
        self.init(context: context)
        self.title = title
    }
}

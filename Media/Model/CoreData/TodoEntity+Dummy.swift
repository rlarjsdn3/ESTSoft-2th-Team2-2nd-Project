//
//  Todo+Dummy.swift
//  Media
//
//  Created by 김건우 on 6/7/25.
//

import Foundation
import CoreData

extension TodoEntity {

    static func mock(insertInto context: NSManagedObjectContext) {
        TodoResponse.mock.forEach { TodoEntity(title: $0.title, insertInto: context) }
    }
}

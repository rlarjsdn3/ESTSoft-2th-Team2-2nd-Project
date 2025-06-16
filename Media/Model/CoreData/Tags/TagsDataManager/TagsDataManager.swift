//
//  TagsDataManager.swift
//  Media
//
//  Created by 전광호 on 6/12/25.
//

import UIKit
import CoreData

class TagsDataManager {
    static let shared = TagsDataManager()
    private init() {}

    private let coreData = CoreDataService.shared
    
    // 카테고리 저장
    func save(category: Category) {
        let tag = TagsEntity(context: coreData.viewContext)
        tag.tag = category.rawValue
        coreData.saveContext()
    }
    
    // 카테고리 삭제
    func delete(category: Category) {
        // 해당 값 필터링
        let predicate = NSPredicate(format: "tag == %@", category.rawValue)
        
        do {
            let tags: [TagsEntity] = try coreData.fetch(predicate)
            tags.forEach { coreData.delete($0) }
        } catch {
            print(error)
        }
    }
    
    // 선택한 카테고리 데이터 전달
    func fetchSelectedCategories() -> [Category] {
        do {
            let tags: [TagsEntity] = try coreData.fetch()
            
            let categories: [Category] = tags.compactMap { tag in
                guard let tag = tag.tag else { return nil }
                return Category(rawValue: tag)
            }
            return categories
        } catch {
            print(error)
            return []
        }
    }
    
    func deleteAll() {
        do {
            try coreData.clearAll()
            coreData.saveContext()
        } catch {
            print(error)
        }
    }
}

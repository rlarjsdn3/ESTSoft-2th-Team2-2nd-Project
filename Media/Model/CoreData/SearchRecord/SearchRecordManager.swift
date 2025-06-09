//
//  SearchRecordEntity+Manager.swift
//  Media
//
//  Created by 백현진 on 6/9/25.
//

import CoreData
import UIKit

protocol SearchManaging {
    /// 새로운 검색 기록을 저장
    /// - Parameter query: 검색어 문자열
    func save(query: String) throws

    /// 최신 검색 기록을 불러옴
    /// - Parameter limit: 가져올 최대 레코드 수 (기본 20)
    /// - Returns: SearchRecord 배열
    func fetchRecent(limit: Int) throws -> [SearchRecordEntity]

    /// 특정 검색 기록을 삭제
    /// - Parameter record: 삭제할 SearchRecord 인스턴스
    func delete(record: SearchRecordEntity) throws

    /// 모든 검색 기록을 일괄 삭제
    func deleteAll() throws
}

final class SearchManager: SearchManaging {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    /// 새로운 검색 기록을 Core Data에 저장
    func save(query: String) throws {
        _ = SearchRecordEntity(context: context, query: query)
        try context.save()
    }

    /// 최신 검색 기록을 timestamp 내림차순으로 가져옼
    func fetchRecent(limit: Int = 20) throws -> [SearchRecordEntity] {
        let req: NSFetchRequest<SearchRecordEntity> = SearchRecordEntity.fetchRequest()
        req.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
        req.fetchLimit = limit
        return try context.fetch(req)
    }

    /// 특정 검색 기록 객체를 삭제
    func delete(record: SearchRecordEntity) throws {
        context.delete(record)
        try context.save()
    }

    /// 모든 검색 기록을 일괄 삭제
    func deleteAll() throws {
        let req = NSFetchRequest<NSFetchRequestResult>(entityName: SearchRecordEntity.id)
        let batch = NSBatchDeleteRequest(fetchRequest: req)
        try context.execute(batch)
        try context.save()
    }
}

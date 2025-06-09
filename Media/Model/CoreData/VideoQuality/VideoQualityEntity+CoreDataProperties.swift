//
//  VideoQualityEntity+CoreDataProperties.swift
//  Media
//
//  Created by 김건우 on 6/9/25.
//
//

import Foundation
import CoreData


extension VideoQualityEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<VideoQualityEntity> {
        return NSFetchRequest<VideoQualityEntity>(entityName: "VideoQualityEntity")
    }

    @NSManaged public var url: URL?
    @NSManaged public var thumbnail: URL?

}

extension VideoQualityEntity : Identifiable {

}

//
//  VideoVariantsEntity+CoreDataProperties.swift
//  Media
//
//  Created by 김건우 on 6/9/25.
//
//

import Foundation
import CoreData


extension VideoVariantsEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<VideoVariantsEntity> {
        return NSFetchRequest<VideoVariantsEntity>(entityName: "VideoVariantsEntity")
    }

    @NSManaged public var large: VideoQualityEntity
    @NSManaged public var medium: VideoQualityEntity
    @NSManaged public var small: VideoQualityEntity
    @NSManaged public var tiny: VideoQualityEntity

}

extension VideoVariantsEntity : Identifiable {

}

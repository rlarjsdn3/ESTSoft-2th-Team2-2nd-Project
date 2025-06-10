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

    @NSManaged public var thumbnail: URL?
    @NSManaged public var url: URL?
    @NSManaged public var large: VideoVariantsEntity?
    @NSManaged public var medium: VideoVariantsEntity?
    @NSManaged public var small: VideoVariantsEntity?
    @NSManaged public var tiny: VideoVariantsEntity?

}

extension VideoQualityEntity : Identifiable {

}

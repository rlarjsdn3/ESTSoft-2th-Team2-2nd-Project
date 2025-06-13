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

    /// 비디오 URL에서 마지막 경로 구성 요소를 추출하여 파일 이름을 반환합니다.
    ///
    /// 이 파일 이름은 실제 디렉터리에 저장된 비디오 파일에 접근할 때 사용할 수 있습니다.
    /// 예를 들어, `https://example.com/videos/sample.mp4` 라는 URL이 주어졌을 경우,
    /// 이 프로퍼티는 `"sample.mp4"`를 반환합니다.
    var videoFileName: String? {
        url?.lastPathComponent
    }
}

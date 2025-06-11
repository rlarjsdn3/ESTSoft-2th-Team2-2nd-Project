//
//  PixabayResponse+Mapping.swift
//  Media
//
//  Created by 김건우 on 6/9/25.
//

import Foundation
import CoreData

extension PixabayResponse.Hit {
    
    /// Pixabay API의 영상 데이터를 Core Data의 PlaylistVideoEntity로 매핑합니다.
    ///
    /// - Parameter context: Core Data에 객체를 삽입할 NSManagedObjectContext입니다.
    /// - Returns: 생성된 PlaylistVideoEntity 객체입니다.
    func mapToPlaylistVideoEntity(
        insertInto context: NSManagedObjectContext
    ) -> PlaylistVideoEntity {
        let entity = PlaylistVideoEntity(context: context)
        entity.id = Int64(self.id)
        entity.pageUrl = self.pageUrl
        entity.tags = self.tags
        entity.duration = Int64(self.duration)
        entity.video = self.videos.mapToVideoVariantsEntity(insertInto: context)
        entity.views = Int64(self.views)
        entity.likes = Int64(self.likes)
        entity.userId = Int64(self.userId)
        entity.user = self.user
        //entity.userImageUrl = self.userImageUrl
        entity.userImageUrl = self.userImageToUrl ?? URL(string: "https://cdn.pixabay.com/user/2024/02/05/16-05-14-742_250x250.jpg")!
        return entity
    }

    /// Pixabay API의 영상 데이터를 Core Data의 PlaybackHistoryEntity로 매핑합니다.
    ///
    /// - Parameter context: Core Data에 객체를 삽입할 NSManagedObjectContext입니다.
    /// - Returns: 생성된 PlaybackHistoryEntity 객체입니다.
    func mapToPlaybackHistoryEntity(
        insertInto context: NSManagedObjectContext
    ) -> PlaybackHistoryEntity {
        let entity = PlaybackHistoryEntity(context: context)
        #if DEBUG
        entity.createdAt = Date().addingTimeInterval(86_400 * Double.random(in: -15...0))
        #else
        entity.createdAt = Date()
        #endif
        entity.id = Int64(self.id)
        entity.tags = self.tags
        entity.duration = Int64(self.duration)
        entity.pageUrl = self.pageUrl
        entity.video = self.videos.mapToVideoVariantsEntity(insertInto: context)
        entity.views = Int64(self.views)
        entity.likes = Int64(self.likes)
        entity.userId = Int64(self.userId)
        entity.user = self.user
        entity.userImageUrl = self.userImageUrl
        return entity
    }
}

typealias PixabayVideoVariants = PixabayResponse.Hit.VideoVariants

extension PixabayVideoVariants {
    
    /// Pixabay API에서 받은 해상도별 영상 정보를 Core Data의 VideoVariantsEntity로 매핑합니다.
    ///
    /// - Parameter context: Core Data에 객체를 삽입할 NSManagedObjectContext입니다.
    /// - Returns: 생성된 VideoVariantsEntity 객체입니다.
    func mapToVideoVariantsEntity(
        insertInto context: NSManagedObjectContext
    ) -> VideoVariantsEntity {
        let entity = VideoVariantsEntity(context: context)
        entity.large = self.large.mapToVideoQualityEntity(insertInto: context)
        entity.medium = self.medium.mapToVideoQualityEntity(insertInto: context)
        entity.small = self.small.mapToVideoQualityEntity(insertInto: context)
        entity.tiny = self.tiny.mapToVideoQualityEntity(insertInto: context)
        return entity
    }
}


typealias PixabayVideoQuality = PixabayResponse.Hit.VideoVariants.VideoQuality

extension PixabayVideoQuality {

    /// Pixabay API에서 받은 단일 해상도의 영상 품질 정보를 Core Data의 VideoQualityEntity로 매핑합니다.
    ///
    /// - Parameter context: Core Data에 객체를 삽입할 NSManagedObjectContext입니다.
    /// - Returns: 생성된 VideoQualityEntity 객체입니다.
    func mapToVideoQualityEntity(
        insertInto context: NSManagedObjectContext
    ) -> VideoQualityEntity {
        let entity = VideoQualityEntity(context: context)
        entity.url = self.url
        entity.thumbnail = self.thumbnail
        return entity
    }
}


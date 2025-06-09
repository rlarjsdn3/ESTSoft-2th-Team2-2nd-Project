//
//  VideoQuailty+Mapping.swift
//  Media
//
//  Created by 김건우 on 6/9/25.
//

import Foundation
import CoreData

extension VideoQualityEntity {

    /// Core Data의 VideoQualityEntity를 기반으로 PixabayVideoQuality 모델 객체를 생성합니다.
    ///
    /// - Returns: 변환된 PixabayVideoQuality 객체입니다.
    func mapToPixabayVideoQuality() -> PixabayVideoQuality {
        let quality = PixabayVideoQuality(
            url: self.url,
            width: 0,
            height: 0,
            size: 0,
            thumbnail: self.thumbnail
        )
        return quality
    }
}

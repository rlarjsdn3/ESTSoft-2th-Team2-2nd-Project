//
//  VideoVariantEntity+Mapping.swift
//  Media
//
//  Created by 김건우 on 6/9/25.
//

import Foundation

extension VideoVariantsEntity {
    
    /// Core Data의 VideoVariantsEntity를 Pixabay API 모델인 PixabayVideoVariants로 변환합니다.
    ///
    /// - Returns: 변환된 PixabayVideoVariants 모델입니다.
    func mapToPixabayVideoVariants() -> PixabayVideoVariants {
        let variants = PixabayVideoVariants(
            large: large.mapToPixabayVideoQuality(),
            medium: medium.mapToPixabayVideoQuality(),
            small: small.mapToPixabayVideoQuality(),
            tiny: tiny.mapToPixabayVideoQuality()
        )
        return variants
    }
}

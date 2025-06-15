//
//  VideoVariants.swift
//  Media
//
//  Created by 김건우 on 6/15/25.
//

import Foundation

/// 서로 다른 품질의 비디오 URL을 저장하고, 품질에 따라 적절한 URL을 반환하는 구조체입니다.
struct VideoVariants {
    
    /// 고화질(large) 비디오의 URL입니다.
    let largeUrl: URL?
    
    /// 중간 화질(medium) 비디오의 URL입니다.
    let mediumUrl: URL?
    
    /// 저화질(small) 비디오의 URL입니다.
    let smallUrl: URL?
    
    /// 매우 저화질(tiny) 비디오의 URL입니다.
    let tinyUrl: URL?
    
    /// 지정된 비디오 품질에 해당하는 URL을 반환합니다.
    /// - Parameter quality: 요청할 비디오 품질
    /// - Returns: 해당 품질에 해당하는 비디오 URL, 존재하지 않으면 `nil`
    func url(for quality: VideoQuality) -> URL? {
        switch quality {
        case .large:  return largeUrl
        case .medium: return mediumUrl
        case .small:  return smallUrl
        case .tiny:   return tinyUrl
        }
    }
}

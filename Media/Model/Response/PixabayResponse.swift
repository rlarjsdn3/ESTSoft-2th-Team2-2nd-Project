//
//  PixabayResponse.swift
//  Media
//
//  Created by 김건우 on 6/8/25.
//

import Foundation

/// 미디어 유형을 나타내는 열거형입니다.
enum MediaType: String, Decodable {
    /// 일반 영상
    case film
    /// 애니메이션 영상
    case animation
}

/// Pixabay API의 응답 전체 구조를 나타내는 모델입니다.
struct PixabayResponse: Decodable {
    /// 전체 검색 결과 수
    let total: Int
    /// 현재 쿼리로 가져온 총 결과 수
    let totalHits: Int
    /// 개별 영상 항목 배열
    let hits: [Hit]
}

extension PixabayResponse {

    /// 개별 영상 정보를 담는 모델입니다.
    struct Hit: Decodable {
        /// 영상의 고유 ID
        let id: Int
        /// 영상 상세 페이지 URL
        let pageUrl: URL
        /// 영상의 미디어 유형
        let type: MediaType
        /// 쉼표로 구분된 태그 문자열
        let tags: String
        /// 영상 길이(초 단위)
        let duration: Int
        /// 다양한 해상도의 영상 정보
        let videos: VideoVariants
        /// 조회 수
        let views: Int
        /// 다운로드 수
        let downloads: Int
        /// 좋아요 수
        let likes: Int
        /// 댓글 수
        let comments: Int
        /// 업로더의 사용자 ID
        let userId: Int
        /// 업로더의 사용자 이름
        let user: String
        /// 업로더의 프로필 이미지 URL(String)
        let userImageUrl: String

        /// 업로더의 프로필 이미지 URL
        var userImageToUrl: URL? {
			URL(string: userImageUrl)
        }

        enum CodingKeys: String, CodingKey {
            case id
            case pageUrl = "pageURL"
            case type
            case tags
            case duration
            case videos
            case views
            case downloads
            case likes
            case comments
            case userId = "user_id"
            case user
            case userImageUrl = "userImageURL"
        }
    }
}

extension PixabayResponse.Hit {

    /// 영상의 다양한 해상도별 버전을 나타내는 모델입니다.
    struct VideoVariants: Decodable {
        /// 대형(보통 3840x2160) 해상도
        let large: VideoQuality
        /// 중형(보통 1920x1080 또는 1280x720) 해상도
        let medium: VideoQuality
        /// 소형(보통 1280x720 또는 960x540) 해상도
        let small: VideoQuality
        /// 최소형(보통 960x540 또는 640x360) 해상도
        let tiny: VideoQuality
    }
}

extension PixabayResponse.Hit.VideoVariants {

    /// 특정 해상도의 영상 품질 정보를 담는 모델입니다.
    struct VideoQuality: Decodable {
        /// 영상 파일 URL (없을 경우 nil)
        let url: URL?
        /// 영상 너비
        let width: Int
        /// 영상 높이
        let height: Int
        /// 파일 크기 (바이트 단위)
        let size: Int
        /// 영상 썸네일 이미지 URL
        let thumbnail: URL?
    }
}

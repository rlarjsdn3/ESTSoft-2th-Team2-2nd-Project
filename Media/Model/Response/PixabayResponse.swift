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
        /// 업로더의 프로필 이미지 URL
        let userImageUrlAbsoulteString: String
        
        /// 업로더의 프로필 이미지 URL 문자열을 기반으로 생성된 URL입니다.
        ///
        /// `userImageUrlAbsoulteString`이 유효한 URL 문자열일 경우 해당 URL을 반환하며,
        /// 그렇지 않으면 `nil`을 반환합니다.
        var userImageUrl: URL? {
            URL(string: userImageUrlAbsoulteString)
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
            case userImageUrlAbsoulteString = "userImageURL"
        }
    }
}

extension PixabayResponse.Hit {

    static let defaultPlayTime: Double = 0.5

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
        let thumbnailAbsoluteString: String
        /// 업로드 영상의 썸네일 URL 문자열을 기반으로 생성된 URL입니다.
        ///
        /// `thumbnailAbsoulteString`이 유효한 URL 문자열일 경우 해당 URL을 반환하며,
        /// 그렇지 않으면 `nil`을 반환합니다.
        var thumbnail: URL? {
        	URL(string: thumbnailAbsoluteString)
        }

        enum CodingKeys: String, CodingKey {
            case url
            case width
            case height
            case size
            case thumbnailAbsoluteString = "thumbnail"
        }

        /// 비디오 URL에서 마지막 경로 구성 요소를 추출하여 파일 이름을 반환합니다.
        ///
        /// 이 파일 이름은 실제 디렉터리에 저장된 비디오 파일에 접근할 때 사용할 수 있습니다.
        /// 예를 들어, `https://example.com/videos/sample.mp4` 라는 URL이 주어졌을 경우,
        /// 이 프로퍼티는 `"sample.mp4"`를 반환합니다.
        var videoFileName: String? {
            url?.lastPathComponent
        }
    }
}

////
////  Video.swift
////  Media
////
////  Created by Jaehun Kim on 6/9/25.
////
//
import Foundation

struct Video: Decodable {
    let id: Int
    let previewURL: String
    let userImageURL: String
    let user: String
    let views: Int
    let likes: Int
    // pixabay는 날짜가 없어서 동영상 시간으로 변경
    let duration: Int
}

struct VideoResponse: Decodable {
    let hits: [Video]
}


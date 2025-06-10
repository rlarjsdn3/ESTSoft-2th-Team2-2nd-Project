
import Foundation

struct VideoCellViewModel {
    let title: String
    let viewCountText: String
    let durationText: String
    let thumbnailURL: URL?
    let profileImageURL: URL?
    let likeCountText: String
    let categoryText: String

    init(
        title: String,
        viewCountText: String,
        durationText: String,
        thumbnailURL: URL?,
        profileImageURL: URL?,
        likeCountText: String,
        tags: String
    ) {
        self.title = title
        self.viewCountText = viewCountText
        self.durationText = durationText
        self.thumbnailURL = thumbnailURL
        self.profileImageURL = profileImageURL
        self.likeCountText = likeCountText
        // 태그값을 카테고리로 변환하기위하여
        let components = tags.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
            self.categoryText = components.first?.capitalized ?? "Unknown"
    }
}
 

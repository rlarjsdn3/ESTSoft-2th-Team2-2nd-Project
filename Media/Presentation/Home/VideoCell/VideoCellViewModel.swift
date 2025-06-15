
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
        viewCount: Int,
        duration: Int,
        thumbnailURL: URL?,
        profileImageURL: URL?,
        likeCount: Int,
        tags: String
    ) {
        self.title = title
        self.viewCountText = VideoCellViewModel.formatViewCount(viewCount)
        self.durationText = VideoCellViewModel.formatDuration(duration)
        self.thumbnailURL = thumbnailURL
        self.profileImageURL = profileImageURL
        self.likeCountText = VideoCellViewModel.formatViewCount(likeCount)

        let components = tags.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        self.categoryText = components.first?.capitalized ?? "Unknown"
    }

    // 뷰모델 내부에 포맷 함수 추가
    private static func formatViewCount(_ count: Int) -> String {
        if count >= 10_000 {
            let value = Double(count) / 10_000
            if abs(value.rounded() - value) < 0.1 {
                return "\(Int(value))만 회"
            } else {
                return String(format: "%.1f만 회", value)
            }
        } else if count >= 1_000 {
            let value = Double(count) / 1_000
            if abs(value.rounded() - value) < 0.1 {
                return "\(Int(value))천 회"
            } else {
                return String(format: "%.1f천 회", value)
            }
        } else {
            return "\(count)회"
        }
    }

    private static func formatDuration(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }
}



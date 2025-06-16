//
//  VideoPlayerService.swift
//  Media
//
//  Created by 김건우 on 6/15/25.
//

import Foundation
import AVKit

/// 다양한 비디오 소스를 기반으로 비디오 재생 기능을 제공하는 서비스 프로토콜입니다.
protocol VideoPlayerService {

    /// 비디오 재생 중 발생할 수 있는 오류를 처리하는 핸들러 타입입니다.
    typealias VideoPlayerErrorHandler = (VideoPlayerError?) -> Void

    /// Pixabay API에서 받은 비디오 데이터를 사용하여 비디오를 재생합니다.
    ///
    /// - Parameters:
    ///   - vc: 비디오 재생을 수행할 뷰 컨트롤러입니다.
    ///   - hits: Pixabay API로부터 응답받은 단일 비디오 항목입니다.
    ///   - onError: 비디오 재생 중 오류가 발생했을 때 호출되는 클로저입니다.
    func playVideo(
        _ vc: UIViewController,
        with hits: PixabayResponse.Hit,
        onError: VideoPlayerErrorHandler?
    )

    /// 사용자가 저장한 재생 목록의 비디오 데이터를 기반으로 비디오를 재생합니다.
    ///
    /// - Parameters:
    ///   - vc: 비디오 재생을 수행할 뷰 컨트롤러입니다.
    ///   - entity: Core Data에 저장된 재생 목록 비디오 엔터티입니다.
    ///   - onError: 비디오 재생 중 오류가 발생했을 때 호출되는 클로저입니다.
    func playVideo(
        _ vc: UIViewController,
        with entity: PlaylistVideoEntity,
        onError: VideoPlayerErrorHandler?
    )

    /// 사용자의 재생 기록에 저장된 비디오 데이터를 기반으로 비디오를 재생합니다.
    ///
    /// - Parameters:
    ///   - vc: 비디오 재생을 수행할 뷰 컨트롤러입니다.
    ///   - entity: Core Data에 저장된 재생 기록 비디오 엔터티입니다.
    ///   - onError: 비디오 재생 중 오류가 발생했을 때 호출되는 클로저입니다.
    func playVideo(
        _ vc: UIViewController,
        with entity: PlaybackHistoryEntity,
        onError: VideoPlayerErrorHandler?
    )
}

/// 비디오 재생을 처리하는 서비스 클래스입니다.
///
/// 지정된 캐싱 객체를 사용하여 비디오를 로컬에 저장한 뒤, AVPlayer를 통해 재생하는 기능을 제공합니다.
/// 내부적으로 AVPlayerItem의 상태를 관찰하여 재생 가능 여부를 판단하며, 에러 발생 시 핸들러를 통해 전달할 수 있습니다.
final class DefaultVideoPlayerService {

    /// 비디오를 다운로드하고 캐시하는 데 사용되는 객체입니다.
    private let cacher: any VideoCacher

    /// AVPlayerItem의 상태를 관찰하기 위한 KVO 옵저버입니다.
    private var observation: NSKeyValueObservation? = nil

    /// `VideoPlayerService`를 초기화합니다.
    ///
    /// - Parameter cacher: 비디오를 캐시할 때 사용할 캐싱 객체입니다.
    init(cacher: any VideoCacher = DefaultVideoCacher()) {
        self.cacher = cacher
    }
}

extension DefaultVideoPlayerService: VideoPlayerService {

    /// Pixabay API 응답에서 전달받은 비디오 데이터를 기반으로 비디오를 재생합니다.
    ///
    /// - Parameters:
    ///   - vc: 비디오 재생을 수행할 뷰 컨트롤러입니다.
    ///   - hits: Pixabay 응답의 단일 비디오 항목입니다.
    ///   - onError: 재생 중 오류 발생 시 호출될 에러 핸들러입니다.
    func playVideo(
        _ vc: UIViewController,
        with hits: PixabayResponse.Hit,
        onError: VideoPlayerErrorHandler? = nil
    ) {
        let variants = VideoVariants(
            largeUrl: hits.videos.large.url,
            mediumUrl: hits.videos.medium.url,
            smallUrl: hits.videos.small.url,
            tinyUrl: hits.videos.tiny.url
        )

        playVideo(vc, with: variants, onError: onError)
    }

    /// 재생 목록에 저장된 비디오 데이터를 기반으로 비디오를 재생합니다.
    ///
    /// - Parameters:
    ///   - vc: 비디오 재생을 수행할 뷰 컨트롤러입니다.
    ///   - entity: 재생 목록에 포함된 비디오 엔터티입니다.
    ///   - onError: 재생 중 오류 발생 시 호출될 에러 핸들러입니다.
    func playVideo(
        _ vc: UIViewController,
        with entity: PlaylistVideoEntity,
        onError: VideoPlayerErrorHandler? = nil
    ) {
        let variants = VideoVariants(
            largeUrl: entity.video?.large.url,
            mediumUrl: entity.video?.medium.url,
            smallUrl: entity.video?.small.url,
            tinyUrl: entity.video?.tiny.url
        )

        playVideo(vc, with: variants, onError: onError)
    }

    /// 재생 기록에 저장된 비디오 데이터를 기반으로 비디오를 재생합니다.
    ///
    /// - Parameters:
    ///   - vc: 비디오 재생을 수행할 뷰 컨트롤러입니다.
    ///   - entity: 사용자의 재생 기록에 해당하는 비디오 엔터티입니다.
    ///   - onError: 재생 중 오류 발생 시 호출될 에러 핸들러입니다.
    func playVideo(
        _ vc: UIViewController,
        with entity: PlaybackHistoryEntity,
        onError: VideoPlayerErrorHandler? = nil
    ) {
        let variants = VideoVariants(
            largeUrl: entity.video?.large.url,
            mediumUrl: entity.video?.medium.url,
            smallUrl: entity.video?.small.url,
            tinyUrl: entity.video?.tiny.url
        )

        playVideo(vc, with: variants, onError: onError)
    }

    /// 사용자의 설정에 따라 적절한 품질의 비디오를 재생합니다.
    ///
    /// 이 메서드는 `UserDefaults`에 저장된 사용자의 선호 비디오 품질 설정을 기반으로,
    /// `VideoVariants` 객체로부터 해당 품질의 URL을 선택해 비디오를 재생합니다.
    /// 저장된 품질이 없거나 해당 품질의 비디오가 존재하지 않는 경우,
    /// 그보다 낮은 품질 중 사용 가능한 첫 번째 URL을 찾아 재생을 시도합니다.
    ///
    /// - Parameters:
    ///   - vc: 비디오 재생을 수행할 뷰 컨트롤러입니다.
    ///   - variants: 다양한 품질의 비디오 URL 정보를 담고 있는 객체입니다.
    ///   - onError: 재생 중 오류가 발생할 경우 호출될 에러 핸들러입니다.
    ///
    /// - Note: Pixabay API 문서에 따르면 대부분의 경우 `tiny`, `small`, `medium` 품질은 제공되며,
    /// 특히 `tiny` 품질이 누락될 가능성은 극히 낮기 때문에 해당 품질 누락에 대한 별도 처리는 하지 않습니다.
    ///
    /// - Warning: 사용자 설정에 저장된 비디오 품질이 존재하지 않거나 `VideoQuality`로 변환할 수 없을 경우 `fatalError`가 발생합니다.
    private func playVideo(
        _ vc: UIViewController,
        with variants: VideoVariants,
        onError: VideoPlayerErrorHandler? = nil
    ) {
        let userDefaults = UserDefaultsService.shared
        let savedQualityRawValue = userDefaults.videoQuality

        // 비디오 품질이 저장되어 있지 않다면
        guard let preferredQuality = VideoQuality(rawValue: savedQualityRawValue) else {
            fatalError("dose not save video quality")
        }

        /// 저장된 비디오 품질에 해당되는 비디오 Url이 존재한다면
        if let preferredUrl = variants.url(for: preferredQuality) {
            playVideo(vc, from: preferredUrl, onError: onError)
        // 저장된 비디오 품질에 해당되는 비디오 Url이 존재하지 않는다면
        } else {
            let availableQualities = VideoQuality.allCases
            /// 저장된 비디오 품질에 해당하는 배열의 인덱스 값이 있다면
            if let firstIndexOfSavedQuality = availableQualities.firstIndex(of: preferredQuality) {
                let candiateQualities = Array(availableQualities[firstIndexOfSavedQuality...])

                // 저장된 비디오 품질보다 아래에 위치한 비디오 품질을 순회하며
                for quality in candiateQualities {
                    // 해당 비디오 품질에 해당하는 비디오 Url이 존재한다면, 비디오를 띄우고 루프 탈출
                    if let preferredUrl = variants.url(for: quality) {
                        playVideo(vc, from: preferredUrl, onError: onError)
                        break
                    }
                }
            /// 저장된 비디오 품질에 해당하는 배열의 인덱스 값이 없다면
            } else {
                fatalError("dose not save video quality")
            }
        }
    }

    /// 사용자의 설정에 따라 적절한 품질의 비디오를 재생합니다.
    ///
    /// 이 메서드는 `UserDefaults`에 저장된 사용자의 선호 비디오 품질 설정을 기반으로,
    /// `VideoVariants` 객체로부터 해당 품질의 URL을 선택해 비디오를 재생합니다.
    /// 저장된 품질이 없거나 해당 품질의 비디오가 존재하지 않는 경우,
    /// 그보다 낮은 품질 중 사용 가능한 첫 번째 URL을 찾아 재생을 시도합니다.
    ///
    /// - Parameters:
    ///   - vc: 비디오 재생을 수행할 뷰 컨트롤러입니다.
    ///   - url: 비디오 URL 입니다.
    ///   - onError: 재생 중 오류가 발생할 경우 호출될 에러 핸들러입니다.
    ///
    /// - Note: Pixabay API 문서에 따르면 대부분의 경우 `tiny`, `small`, `medium` 품질은 제공되며,
    /// 특히 `tiny` 품질이 누락될 가능성은 극히 낮기 때문에 해당 품질 누락에 대한 별도 처리는 하지 않습니다.
    ///
    /// - Warning: 사용자 설정에 저장된 비디오 품질이 존재하지 않거나 `VideoQuality`로 변환할 수 없을 경우 `fatalError`가 발생합니다.
    func playVideo(
        _ vc: UIViewController,
        from url: URL,
        onError: VideoPlayerErrorHandler? = nil
    ) {
        observation?.invalidate()

        let player = AVPlayer(url: url)
        let playerVC = PiPEnabledPlayerViewController()
        playerVC.player = player

        self.observation = player.currentItem?.observe(\.status, options: [.new]) { [weak self] playerItem, _ in
            switch playerItem.status {
            case .readyToPlay:
                player.play()
                print("🔹 Played Video:", url)
                vc.present(playerVC, animated: true)
            case .failed:
                guard let error = playerItem.error,
                      let resolvedError = self?.resolvedError(error) else {
                    onError?(nil)
                    return
                }
                onError?(resolvedError)
            default:
                break
            }
        }

    }

    /// 시스템에서 발생한 오류를 `VideoPlayerError`로 변환합니다.
    ///
    /// 네트워크 관련 오류를 보다 명확한 앱 도메인 오류 타입으로 매핑하여 처리할 수 있도록 합니다.
    /// 예를 들어, 인터넷 연결이 끊어진 경우 `.notConnectedToInternet`으로 변환되며, 그 외의 오류는 `.generic`으로 래핑됩니다.
    ///
    /// - Parameter error: 원본 `Error` 객체입니다. 주로 네트워크나 AVPlayer 관련 오류가 들어옵니다.
    /// - Returns: 변환된 `VideoPlayerError` 열거형 값입니다.
    private func resolvedError(_ error: Error) -> VideoPlayerError {
        let errorCode = URLError.Code(rawValue: (error as NSError).code)
        switch errorCode {
        case .notConnectedToInternet: return .notConnectedToInternet
        default: return .generic(error)
        }
    }





    /// 지정된 URL의 비디오를 다운로드하여 캐시한 후 재생합니다.
    ///
    /// 이 메서드는 비디오 URL을 기반으로 파일을 캐시한 뒤, AVPlayer를 통해 비디오를 재생합니다.
    /// AVPlayerItem의 상태를 관찰하여 재생 가능 여부를 확인하고,
    /// 재생 준비가 완료되면 자동으로 재생이 시작됩니다.
    ///
    /// - Note: 이 메서드는 아직 완전히 구현되지 않았으며, 사용이 권장되지 않습니다. 향후 구현 예정입니다.
    ///
    /// - Parameters:
    ///   - url: 재생할 비디오의 원본 URL입니다.
    ///   - cacher: 비디오를 다운로드하고 캐시하는 데 사용할 캐싱 객체입니다. 기본값은 `DefaultVideoCacher`입니다.
    /// - Returns: 다운로드 작업을 취소할 수 있는 객체를 반환합니다. 이미 캐시된 경우에는 `nil`을 반환합니다.
    @available(*, deprecated, message: "Not yet implemented")
    @discardableResult
    func playVideo(
        with url: URL,
        using cacher: any VideoCacher = DefaultVideoCacher()
    ) -> (any NetworkCancellable)? {

        observation?.invalidate()

        return cacher.download(from: url) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let localUrl):
                let item = AVPlayerItem(url: localUrl)
                let player = AVPlayer(playerItem: item)
                let vc = AVPlayerViewController()
                vc.player = player

                self.observation = player.observe(\.status, options: [.new]) { playerItem, _ in
                    switch playerItem.status {
                    case .readyToPlay:
                        player.play()
                    case .failed:
                        print("PlayerItem failed to load: \(playerItem.error?.localizedDescription ?? "Unknown error")")
                    default:
                        break
                    }
                }
                vc.present(vc, animated: true)

            case .failure(let error):
                print("PlayerItem failed to load: \(error.localizedDescription)")
            }
        }
    }

}

final class PiPEnabledPlayerViewController: AVPlayerViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // PiP 기능 활성화 (영상이 작은 창으로 재생되도록 허용)
        self.allowsPictureInPicturePlayback = true
        // 사용자가 별도로 PiP 버튼을 누르지 않아도
        // 앱이 백그라운드로 전환될 때 자동으로 PiP 모드를 시작할 수 있도록 허용
        self.canStartPictureInPictureAutomaticallyFromInline = true
    }
}

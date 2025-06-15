//
//  VideoPlayable.swift
//  Media
//
//  Created by 김건우 on 6/13/25.
//

import UIKit
import AVKit

enum VideoPlayerError: Error {
    ///
    case notConnectedToInternet
    ///
    case generic(Error)
}

/// 비디오를 재생할 수 있는 기능을 정의하는 프로토콜입니다.
protocol VideoPlayable: AnyObject {

    /// AVPlayerItem의 상태를 감시하기 위한 KVO 옵저버입니다.
    var observation: NSKeyValueObservation? { get set }
}

extension VideoPlayable where Self: UIViewController {

    typealias VideoPlayerErrorHandler = (VideoPlayerError?) -> Void

    /// Pixabay API 응답에서 전달받은 비디오 데이터를 기반으로 비디오를 재생합니다.
    /// - Parameter hits: Pixabay 응답의 단일 비디오 항목
    func playVideo(with hits: PixabayResponse.Hit, onError: VideoPlayerErrorHandler? = nil) {
        let variants = VideoVariants(
            largeUrl: hits.videos.large.url,
            mediumUrl: hits.videos.medium.url,
            smallUrl: hits.videos.small.url,
            tinyUrl: hits.videos.tiny.url
        )
        
        playVideo(with: variants, onError: onError)
    }
    
    /// 재생 목록에 저장된 비디오 데이터를 기반으로 비디오를 재생합니다.
    /// - Parameter entity: 재생 목록에 저장된 비디오 엔터티
    func playVideo(with entity: PlaylistVideoEntity, onError: VideoPlayerErrorHandler? = nil) {
        let variants = VideoVariants(
            largeUrl: entity.video?.large.url,
            mediumUrl: entity.video?.medium.url,
            smallUrl: entity.video?.small.url,
            tinyUrl: entity.video?.tiny.url
        )
        
        playVideo(with: variants, onError: onError)
    }

    /// 재생 목록에 저장된 비디오 데이터를 기반으로 비디오를 재생합니다.
    /// - Parameter entity: 재생 목록에 저장된 비디오 엔터티
    func playVideo(with entity: PlaybackHistoryEntity, onError: VideoPlayerErrorHandler? = nil) {
        let variants = VideoVariants(
            largeUrl: entity.video?.large.url,
            mediumUrl: entity.video?.medium.url,
            smallUrl: entity.video?.small.url,
            tinyUrl: entity.video?.tiny.url
        )
        
        playVideo(with: variants, onError: onError)
    }
    
    /// 사용자의 설정에 따라 적절한 품질의 비디오를 재생합니다.
    /// - Parameter variants: 품질별 비디오 URL 정보를 담고 있는 객체
    ///
    /// - Note: Pixabay API 공식 문서에 따르면 large 사이즈를 제외한 대부분의 비디오 품질(tiny, small, medium)은 일반적으로 제공됩니다. 따라서 가장 낮은 품질의 비디오(tiny)조차 없을 가능성은 희박하므로, tiny 품질이 없을 경우를 고려한 처리는 구현하지 않았습니다.
    private func playVideo(with variants: VideoVariants, onError: VideoPlayerErrorHandler? = nil) {
        let userDefaults = UserDefaultsService.shared
        let savedQualityRawValue = userDefaults.videoQuality
        
        // 비디오 품질이 저장되어 있지 않다면
        guard let preferredQuality = VideoQuality(rawValue: savedQualityRawValue) else {
            fatalError("dost not save video quality")
        }
        
        /// 저장된 비디오 품질에 해당되는 비디오 Url이 존재한다면
        if let preferredUrl = variants.url(for: preferredQuality) {
            playVideo(from: preferredUrl, onError: onError)
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
                        playVideo(from: preferredUrl, onError: onError)
                        break
                    }
                }
            /// 저장된 비디오 품질에 해당하는 배열의 인덱스 값이 없다면
            } else {
                fatalError("dost not save video quality")
            }
        }
    }
    
    /// 주어진 URL의 비디오를 재생합니다.
    ///
    /// 이 메서드는 URL을 기반으로 AVPlayer를 구성하고, AVPlayerViewController를 생성하여 화면에 표시합니다.
    /// AVPlayerItem의 상태를 관찰하여 재생 준비가 완료되면 자동으로 재생을 시작하며,
    /// 실패한 경우 콘솔에 오류 메시지를 출력합니다.
    ///
    /// - Parameter url: 재생할 비디오의 원격 또는 로컬 URL입니다.
    ///
    func playVideo(from url: URL, onError: VideoPlayerErrorHandler? = nil) {
        observation?.invalidate()

        let player = AVPlayer(url: url)
        let vc = AVPlayerViewController()
        vc.player = player

        self.observation = player.currentItem?.observe(\.status, options: [.new]) { [weak self] playerItem, _ in
            switch playerItem.status {
            case .readyToPlay:
                player.play()
                print("🔹 Played Video:", url)
                self?.present(vc, animated: true)
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
    
    /// <#Description#>
    /// - Parameter error: <#error description#>
    /// - Returns: <#description#>
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
                
                self.present(vc, animated: true) {
                    print("PlayerViewController presented")
                }
                
                
            case .failure(let error):
                print("PlayerItem failed to load: \(error.localizedDescription)")
            }
        }
    }
}

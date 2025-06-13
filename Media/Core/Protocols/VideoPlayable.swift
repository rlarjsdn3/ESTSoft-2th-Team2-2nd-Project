//
//  VideoPlayable.swift
//  Media
//
//  Created by 김건우 on 6/13/25.
//

import UIKit
import AVKit

/// 비디오를 재생할 수 있는 기능을 정의하는 프로토콜입니다.
protocol VideoPlayable: AnyObject {

    /// AVPlayerItem의 상태를 감시하기 위한 KVO 옵저버입니다.
    var observation: NSKeyValueObservation? { get set }
}

extension VideoPlayable where Self: UIViewController {

    /// 주어진 URL의 비디오를 재생합니다.
    ///
    /// 이 메서드는 URL을 기반으로 AVPlayer를 구성하고, AVPlayerViewController를 생성하여 화면에 표시합니다.
    /// AVPlayerItem의 상태를 관찰하여 재생 준비가 완료되면 자동으로 재생을 시작하며,
    /// 실패한 경우 콘솔에 오류 메시지를 출력합니다.
    ///
    /// - Parameter url: 재생할 비디오의 원격 또는 로컬 URL입니다.
    func playVideo(from url: URL) {
        observation?.invalidate()

        let player = AVPlayer(url: url)
        let vc = AVPlayerViewController()
        vc.player = player

        self.observation = player.currentItem?.observe(\.status, options: [.new]) { playerItem, _ in
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

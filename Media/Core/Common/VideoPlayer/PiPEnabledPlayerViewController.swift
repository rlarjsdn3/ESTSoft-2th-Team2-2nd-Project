//
//  PiPEnabledPlayerViewController.swift
//  Media
//
//  Created by 강민지 on 6/15/25.
//

import UIKit
import AVKit

/// PiP 재생을 지원하는 AVPlayerViewController 서브클래스
/// AVPlayerViewController를 상속받아 PiP 관련 설정을 커스터마이징
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

/// 전달받은 URL로 PiP 가능한 영상 플레이어 화면을 생성하고 전체 화면으로 표시
/// - Parameters:
///   - parent: 현재 ViewController (present 기준)
///   - url: 재생할 영상의 URL
func presentPiPVideoPlayer(from parent: UIViewController, with url: URL) {
    let player = AVPlayer(url: url)
    let pipVC = PiPEnabledPlayerViewController()
    
    // AVPlayer 설정
    pipVC.player = player
    pipVC.modalPresentationStyle = .fullScreen
    
    // 모달 방식으로 PiP 지원 플레이어를 띄우고 재생 시작
    parent.present(pipVC, animated: true) {
        player.play()
    }
}

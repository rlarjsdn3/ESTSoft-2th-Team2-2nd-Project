//
//  PIPVideoPlayerViewController.swift
//  Media
//
//  Created by 김건우 on 6/16/25.
//

import AVKit

final class PiPEnabledPlayerViewController: AVPlayerViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // PiP(Picture in Picture) 기능을 활성화하여,
        // 비디오 재생 화면이 작은 창으로 축소되어 다른 앱 위에서 재생될 수 있도록 허용합니다.
        self.allowsPictureInPicturePlayback = true

        // 사용자가 PiP 버튼을 누르지 않아도,
        // 앱이 백그라운드로 전환될 때 자동으로 PiP 모드가 시작되도록 허용합니다.
        self.canStartPictureInPictureAutomaticallyFromInline = true
    }
}

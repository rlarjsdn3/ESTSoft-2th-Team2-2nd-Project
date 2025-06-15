//
//  VideoCacherLogger.swift
//  Media
//
//  Created by 김건우 on 6/12/25.
//

import Foundation

protocol VideoCacherLogger {
    /// 비디오 다운로드 및 불러오기 중 발생한 에러를 로그로 출력합니다.
    /// - Parameter error: 발생한 에러 객체입니다.
    func log(error: any Error)
}

struct DefaultVideoCacherLogger: VideoCacherLogger {

    /// 비디오 다운로드 및 불러오기 중 발생한 에러를 로그로 출력합니다.
    /// - Parameter error: 발생한 에러 객체입니다.
    func log(error: any Error) {
        print("VideoCacherLogger: \(error)")
    }
}


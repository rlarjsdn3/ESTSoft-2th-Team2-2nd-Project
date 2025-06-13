//
//  UserDefaultsKeys.swift
//  UserDefaultsService
//
//  Created by 김건우 on 6/5/25.
//

import Foundation

/// UserDefaults에서 사용할 키들을 정의하는 구조체입니다.
struct UserDefaultsKeys { }

extension UserDefaultsKeys {
    /// 온보딩 완료 여부를 저장하는 키입니다.
    /// 기본값은 `false`입니다.
    var hasCompletedOnboarding: UserDefaultsKey<Bool> {
        UserDefaultsKey(name: "hasCompletedOnboarding_v1", defaultValue: false)
    }
    ///
    var isFirstLaunch: UserDefaultsKey<Bool> {
        UserDefaultsKey(name: "isFirstLaunch", defaultValue: true)
    }
    /// 사용자 이름을 저장하는 키입니다.
    /// 기본값은 `nil`입니다.
    var userName: UserDefaultsKey<String?> {
        UserDefaultsKey(name: "userName", defaultValue: nil)
    }

    /// [필터] 카테고리 배열을 저장하는 키입니다.
    var filterCategories: UserDefaultsKey<String?> {
        UserDefaultsKey(name: "filterCategories", defaultValue: nil)
    }

    /// [필터] 인기/최신 정렬 배열을 저장하는 키입니다.
    var filterOrders: UserDefaultsKey<String?> {
        UserDefaultsKey(name: "filterOrders", defaultValue: nil)
    }

    /// [필터] 영상 길이 배열을 저장하는 키입니다.
    var filterDurations: UserDefaultsKey<String?> {
        UserDefaultsKey(name: "filterDurations", defaultValue: nil)
    }

    /// 사용자 이메일을 저장하는 키입니다.
    /// 기본값은 `nil`입니다.
    var userEmail: UserDefaultsKey<String?> {
        UserDefaultsKey(name: "userEmail", defaultValue: nil)
    }
    /// 영상 해상도를 저장하는 키입니다.
    /// 기본값은 `Medium`입니다.
    var videoQuality: UserDefaultsKey<String> {
        UserDefaultsKey(name: "video_quality", defaultValue: VideoQuality.medium.rawValue)

    }
}

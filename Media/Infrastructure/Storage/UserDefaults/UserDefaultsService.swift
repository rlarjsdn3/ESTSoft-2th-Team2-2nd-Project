//
//  UserDefaultsService.swift
//  UserDefaultsService
//
//  Created by 김건우 on 6/5/25.
//

import Foundation

@dynamicMemberLookup
final class UserDefaultsService {

    /// 전역에서 접근 가능한 싱글톤 인스턴스입니다.
    static let shared = UserDefaultsService()

    /// 사용자 기본값을 저장하고 불러오기 위한 UserDefaults 인스턴스입니다.
    private(set) var userDefaults: UserDefaults

    /// 기본 초기화 메서드입니다.
    /// 빌드 환경에 따라 다른 suiteName으로 UserDefaults를 생성합니다.
    private init() {
#if DEBUG
        userDefaults = UserDefaults(suiteName: "com.userDefautls.media.debug")!
#else
        userDefaults = UserDefaults(suiteName: "com.userDefautls.media.release")!
#endif
    }

    /// 지정된 suiteName으로 UserDefaults를 초기화합니다.
    /// - Parameter suiteName: 사용할 UserDefaults의 suite 이름
    init(suiteName: String) {
        userDefaults = UserDefaults(suiteName: suiteName)!
    }

    /// 주어진 문자열 키를 사용해 값을 저장합니다.
    /// - Parameters:
    ///   - value: 저장할 값
    ///   - name: UserDefaults에 사용할 키 문자열
    func set<Value>(
        _ value: Value,
        forKey name: String
    ) {
        userDefaults.set(value, forKey: name)
    }

    /// 키 경로를 통해 정의된 키를 사용해 값을 저장합니다.
    /// - Parameters:
    ///   - value: 저장할 값
    ///   - keyPath: `UserDefaultsKeys`의 키 경로
    func set<Value>(
        _ value: Value,
        forKey keyPath: KeyPath<UserDefaultsKeys, UserDefaultsKey<Value>>
    ) {
        let resolvedKey = resolvedKey(keyPath)
        set(value, forKey: resolvedKey.name)
    }

    /// 키 경로를 통해 정의된 키로부터 값을 가져옵니다.
    /// 값이 없을 경우 기본값을 반환합니다.
    /// - Parameter keyPath: `UserDefaultsKeys`의 키 경로
    /// - Returns: 저장된 값 또는 기본값
    func get<Value>(
        forKey keyPath: KeyPath<UserDefaultsKeys, UserDefaultsKey<Value>>
    ) -> Value {
        let resolvedKey = resolvedKey(keyPath)
        return get(forKey: resolvedKey.name) ?? resolvedKey.defaultValue
    }

    /// 문자열 키를 통해 값을 가져옵니다.
    /// - Parameter name: UserDefaults에 저장된 키 문자열
    /// - Returns: 저장된 값 또는 nil
    func get<Value>(
        forKey name: String
    ) -> Value? {
        return userDefaults.object(forKey: name) as? Value
    }

    /// 주어진 문자열 키에 해당하는 값을 UserDefaults에서 제거합니다.
    /// - Parameter name: 제거할 값의 키 문자열
    func clear(forKey name: String) {
        userDefaults.removeObject(forKey: name)
    }

    /// 키 경로를 통해 정의된 키에 해당하는 값을 UserDefaults에서 제거합니다.
    /// - Parameter keyPath: `UserDefaultsKeys`의 키 경로
    func clear<Value>(forKey keyPath: KeyPath<UserDefaultsKeys, UserDefaultsKey<Value>>) {
        clear(forKey: resolvedKey(keyPath).name)
    }

    /// UserDefaults에 저장된 모든 값을 제거합니다.
    func clearAll() {
        let dictionary = userDefaults.dictionaryRepresentation()
        dictionary.keys.forEach(clear(forKey:))
    }
}


extension UserDefaultsService {

    /// `UserDefaultsKeys`에 정의된 키 경로를 통해 값을 가져오거나 설정할 수 있는 서브스크립트입니다.
    /// - Parameter keyPath: `UserDefaultsKeys`의 프로퍼티에 대한 키 경로
    /// - Returns: 해당 키에 저장된 값 또는 새로 설정한 값
    subscript<Value>(dynamicMember keyPath: KeyPath<UserDefaultsKeys, UserDefaultsKey<Value>>) -> Value {
        get { get(forKey: keyPath) }
        set { set(newValue, forKey: keyPath) }
    }
}


extension UserDefaultsService {

    /// KeyPath를 통해 UserDefaultsKey 객체를 반환합니다.
    ///
    /// - Parameter keyPath: UserDefaultsKeys 내부의 특정 키에 대한 KeyPath입니다.
    /// - Returns: 해당 KeyPath에 해당하는 UserDefaultsKey 객체입니다.
    private func resolvedKey<Value>(_ keyPath: KeyPath<UserDefaultsKeys, UserDefaultsKey<Value>>) -> UserDefaultsKey<Value> {
        UserDefaultsKeys()[keyPath: keyPath]
    }
}

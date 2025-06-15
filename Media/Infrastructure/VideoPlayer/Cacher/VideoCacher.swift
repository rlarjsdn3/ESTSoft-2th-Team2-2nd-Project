//
//  VideoCacher.swift
//  Media
//
//  Created by 김건우 on 6/12/25.
//

import Foundation
import AVFoundation

/// 비디오 캐시 처리 중 발생할 수 있는 오류 유형을 정의합니다.
enum VideoCacherError: Error {

    /// 임시 파일을 지정된 위치로 이동하는 데 실패한 경우
    case cannotMoveFile

    /// 저장된 비디오 파일을 삭제하는 데 실패한 경우
    case cannotDeleteFile

    /// 저장된 비디오 파일을 읽는 데 실패한 경우
    case cannotReadFile

    /// 이미 해당 경로에 동일한 이름의 파일이 존재하는 경우
    case alreadyExistsFile

    /// 네트워크 요청 중 오류가 발생한 경우. 관련 `DataTransferError`를 포함합니다.
    case networkFailure(DataTransferError)
}


/// 비디오 파일의 다운로드, 삭제, 캐시 관리를 담당하는 캐싱 인터페이스입니다.
protocol VideoCacher {

    /// 비디오 파일을 지정된 URL에서 다운로드하여 캐시 디렉터리에 저장합니다.
    /// - Parameters:
    ///   - url: 다운로드할 원본 URL
    ///   - completion: 다운로드 결과를 반환하는 클로저. 성공 시 로컬 URL을 반환합니다.
    /// - Returns: 다운로드 작업을 취소할 수 있는 객체를 반환합니다.
    func download(
        from url: URL,
        completion: ((Result<URL, VideoCacherError>) -> Void)?
    ) -> (any NetworkCancellable)?

    /// 지정된 URL의 파일을 캐시 디렉터리에서 삭제합니다.
    /// - Parameter url: 삭제할 파일의 원본 URL
    func delete(from url: URL) throws

    /// 캐시 디렉터리에 저장된 모든 비디오 파일을 삭제합니다.
    func deleteAll() throws
}

final class DefaultVideoCacher {

    /// 파일을 관리하는 FileManager 인스턴스입니다.
    private let cacher: FileManager

    /// 비디오 다운로드에 사용되는 데이터 전송 서비스입니다.
    private let service: any DataTransferService

    /// 캐싱 오류를 로깅하는 로거입니다.
    private let logger: any VideoCacherLogger

    /// 기본 비디오 캐싱 객체를 초기화합니다.
    /// - Parameters:
    ///   - cacher: 파일 시스템을 관리할 FileManager (기본값: FileManager.default)
    ///   - dataTransferService: 네트워크를 통한 데이터 전송 서비스
    ///   - errorLogger: 오류 로깅을 담당하는 객체
    init(
        cacher: FileManager = FileManager.default,
        service: any DataTransferService = DefaultDataTransferService(),
        logger: any VideoCacherLogger = DefaultVideoCacherLogger()
    ) {
        self.cacher = cacher
        self.service = service
        self.logger = logger
    }
}


extension DefaultVideoCacher: VideoCacher {
    
    /// 지정된 URL에서 비디오 파일을 다운로드하여 캐시 디렉터리에 저장합니다.
    /// 이미 동일한 파일이 존재하면 다운로드를 생략하고 해당 경로를 반환합니다.
    /// 
    /// - Parameters:
    ///   - url: 다운로드할 비디오 URL
    ///   - completion: 완료 시 호출되는 클로저. 성공 시 로컬 URL을 전달합니다.
    /// - Returns: 다운로드 작업 객체 (취소 가능), 이미 존재하는 경우 nil 반환
    func download(
        from url: URL,
        completion: ((Result<URL, VideoCacherError>) -> Void)? = nil
    ) -> (any NetworkCancellable)? {
        
        let fileName = url.lastPathComponent
        let cacheDirectoryUrl = cacher.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let localUrl = cacheDirectoryUrl.appendingPathComponent(fileName)
        
        if cacher.fileExists(atPath: localUrl.path) {
            completion?(.success(localUrl))
            return nil
        }
        
        let endpoint = Endpoint<URL>(baseUrl: url.absoluteString)
        
        return service.download(endpoint, on: DispatchQueue.main) { result in
            switch result {
            case .success(let tempUrl):
                do {
                    try self.cacher.moveItem(at: tempUrl, to: localUrl)
                    completion?(.success(localUrl))
                } catch {
                    completion?(.failure(VideoCacherError.cannotMoveFile))
                }
            case .failure(let error):
                let resolvedErorr = self.resolvedError(error)
                completion?(.failure(resolvedErorr))
            }
        }
    }
    
    /// 지정된 URL의 비디오 파일을 캐시 디렉터리에서 삭제합니다.
    /// - Parameter url: 삭제할 비디오의 원본 URL
    func delete(from url: URL) throws {
        
        let fileName = url.lastPathComponent
        let cacheDirectoryUrl = cacher.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let localUrl = cacheDirectoryUrl.appendingPathComponent(fileName)
        
        if !cacher.fileExists(atPath: localUrl.path) {
            throw VideoCacherError.alreadyExistsFile
        }
        
        do {
            try cacher.removeItem(atPath: localUrl.path)
        } catch {
            throw VideoCacherError.cannotDeleteFile
        }
    }
    
    /// 캐시 디렉터리에 저장된 모든 비디오 파일을 삭제합니다.
    func deleteAll() throws {
        
        let cacheDirectoryUrl = cacher.urls(for: .cachesDirectory, in: .userDomainMask).first!
        
        do {
            let fileNames = try cacher.contentsOfDirectory(atPath: cacheDirectoryUrl.path)

            for fileName in fileNames {
                let localUrls = cacheDirectoryUrl.appendingPathComponent(fileName)
                try delete(from: localUrls)
            }
        } catch {
            throw VideoCacherError.cannotDeleteFile
        }
    }
    
    
    
    private func resolvedError(_ error: DataTransferError) -> VideoCacherError {
        VideoCacherError.networkFailure(error)
    }
}


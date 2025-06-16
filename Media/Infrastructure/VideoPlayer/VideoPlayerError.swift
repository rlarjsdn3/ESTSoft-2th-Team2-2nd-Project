//
//  VideoPlayerError.swift
//  Media
//
//  Created by 김건우 on 6/15/25.
//

import Foundation

///
enum VideoPlayerError: Error {
    ///
    case notConnectedToInternet
    ///
    case generic(Error)
}

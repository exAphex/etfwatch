//
//  Error.swift
//  etfwatch
//
//  Created by Aydin Tekin on 11.04.21.
//

import Foundation

enum HTTPError: Error {
    case responseError(code: Int)
    case genericError(cause: String)
}

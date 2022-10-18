//
// Error.swift
//  
//
//  Created by Ain Obara on 2022/10/17.
//

import Foundation

public enum NetworkError: Error {

    case sessionError
    case invalidRequest
    case invalidResponse
    case interception(Error)
    case unknown
}

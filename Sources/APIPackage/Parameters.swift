//
//  Parameters.swift
//  
//
//  Created by Ain Obara on 2022/10/17.
//

import Foundation

public var parameters = Parameters()

public struct Parameters {

    public var showLog = false
}

func log(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    if parameters.showLog {
        print(items, separator: separator, terminator: terminator)
    }
}

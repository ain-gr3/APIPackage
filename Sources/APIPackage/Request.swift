//
//  Request.swift
//  
//
//  Created by Ain Obara on 2022/10/17.
//

import Foundation


// MARK: - HTTPRequest

public enum HTTPMethod: String {

    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case update = "UPDATE"
}

public protocol HTTPRequestBody {
    func data() -> Data?
}

public struct HTTPQuery {

    public let key: String
    public let value: Any?
}

public struct HTTPHeader {

    public let key: String
    public let value: Any?
}

public protocol HTTPRequest {

    var method: HTTPMethod { get }
    var baseURL: String { get }
    var path: String { get }
    var queries: [HTTPQuery] { get }
    var headers: [HTTPHeader] { get }
    var body: HTTPRequestBody? { get }
}

// MARK: - APIRequest

public protocol APIRequest: HTTPRequest {

    associatedtype SuccessResponse

    func intercept(urlResponse: HTTPURLResponse, data: Data?) throws -> Void
    func parse(_ data: Data) throws -> SuccessResponse
}

extension APIRequest where SuccessResponse == Void {

    func parse(_ data: Data) throws -> Void {}
}

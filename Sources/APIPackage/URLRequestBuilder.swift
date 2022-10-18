//
//  URLRequestBuilder.swift
//  
//
//  Created by Ain Obara on 2022/10/17.
//

import Foundation

struct URLRequestBuilder {

    func build<Request: HTTPRequest>(_ request: Request) -> URLRequest? {
        var compornents = URLComponents(string: request.baseURL);

        compornents?.path = request.path
        compornents?.queryItems = request
            .queries
            .filter { $0.value != nil }
            .map { URLQueryItem(name: $0.key, value: String(describing: $0.value!)) }

        guard let url = compornents?.url else {
            return nil
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.httpBody = request.body?.data()
        urlRequest.allHTTPHeaderFields = Dictionary(
            uniqueKeysWithValues: request.headers
                .filter { $0.value != nil }
                .map { ($0.key, String(describing: $0.value)) }
        )

        return urlRequest
    }
}

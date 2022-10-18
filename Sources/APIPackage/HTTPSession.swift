//
//  HTTPSession.swift
//  
//
//  Created by Ain Obara on 2022/10/17.
//

import Foundation

protocol HTTPSession {

    func dataTask<Request: HTTPRequest>(_ request: Request, completion: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask?
}

struct HTTPSessionImpl: HTTPSession {

    let session: URLSession?
    let urlRequestBuilder: URLRequestBuilder

    func dataTask<Request: HTTPRequest>(_ request: Request, completion: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask? {

        guard let urlRequest = urlRequestBuilder.build(request) else {
            return nil
        }

        log("【APIPackage Session】\(String(describing: urlRequest.url))")

        let task = session?.dataTask(with: urlRequest) { data, response, error in

            completion(data, response, error)
        }
        task?.resume()
        return task
    }
}

//
//  APISession.swift
//  
//
//  Created by Ain Obara on 2022/10/17.
//

import Foundation

public struct APISession {

    private let httpSession: HTTPSession

    init(httpSession: HTTPSession) {
        self.httpSession = httpSession
    }

    @discardableResult
    public func send<Request: APIRequest>(
        _ request: Request,
        completion: @escaping (Result<Request.SuccessResponse, NetworkError>) -> Void
    ) -> URLSessionDataTask? {

        let task = httpSession.dataTask(request) { data, response, error in

            switch (data, response as? HTTPURLResponse, error) {
            case (_, _, .some):
                completion(.failure(.sessionError))

            case (_, .some(let urlResponse), .none):
                do {
                    try request.intercept(urlResponse: urlResponse, data: data)

                    if Request.SuccessResponse.self == Void.self {
                        completion(.success(() as! Request.SuccessResponse))
                    } else if let data = data {
                        do {
                            let successObject = try request.parse(data)
                            completion(.success(successObject))
                        } catch {
                            completion(.failure(.invalidResponse))
                        }
                    }
                } catch let interception {
                    completion(.failure(.interception(interception)))
                }
            default:
                completion(.failure(.unknown))
            }
        }

        if task == nil {
            completion(.failure(.invalidRequest))
        }

        return task
    }
}

extension APISession {

    public init(_ session: URLSession) {
        self.init(
            httpSession: HTTPSessionImpl(
                session: session,
                urlRequestBuilder: URLRequestBuilder()
            )
        )
    }
}

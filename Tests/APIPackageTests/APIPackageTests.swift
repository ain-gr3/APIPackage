import XCTest
@testable import APIPackage

struct Response: Decodable {

    let totalCount: Int
    let items: [Repository]
}

struct Repository: Decodable {

    let fullName: String
    let url: URL
}

enum GitHubError: Error {

    case someError
    case undefined
}

struct GitHubRequest: APIRequest {

    typealias SuccessResponse = Response

    var method: HTTPMethod {
        .get
    }

    var baseURL: String {
        "https://api.github.com"
    }

    var path: String {
        "/search/repositories"
    }

    var queries: [HTTPQuery]

    var headers: [HTTPHeader] {
        [
            HTTPHeader(key: "Accept", value: "application/vnd.github+json")
        ]
    }

    let body: HTTPRequestBody? = nil

    func intercept(urlResponse: HTTPURLResponse, data: Data?) throws {
        switch urlResponse.statusCode {
        case 200:
            break;
        case 400...499:
            throw GitHubError.someError
        default:
            throw GitHubError.undefined
        }
    }

    func parse(_ data: Data) throws -> Response {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        return try decoder.decode(Response.self, from: data)
    }
}

struct HTTPSessionMock: HTTPSession {

    func dataTask<Request>(
        _ request: Request,
        completion: @escaping (Data?, URLResponse?, Error?) -> Void
    ) -> URLSessionDataTask? where Request : APIPackage.HTTPRequest {

        guard let url = Bundle.module.url(forResource: "repositories", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            XCTFail("couldn't get reoisitories.json")
            return nil
        }

        completion(
            data,
            HTTPURLResponse(
                url: url,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            ),
            nil
        )
        return URLSessionDataTask()
    }
}

final class APIPackageTests: XCTestCase {

    func testAPISession() {
        APIPackage.parameters.showLog = true

        let expectation: XCTestExpectation? = expectation(description: "session")

        let apiSession = APISession(httpSession: HTTPSessionMock())

        let request = GitHubRequest(queries: [HTTPQuery(key: "q", value: "Swift")])

        apiSession.send(request) { result in
            switch result {
            case .success(let success):
                print(success)
            case .failure(let error):
                switch error {
                case .interception, .sessionError:
                    print(error)
                default:
                    XCTFail()
                }
            }
            expectation?.fulfill()
        }

        waitForExpectations(timeout: 10, handler: nil)
    }
}

//
//  GithubAPIClient.swift
//  PerfectAPIClientTests
//
//  Created by Sven Tiigi on 28.10.17.
//

@testable import PerfectAPIClient
import PerfectHTTP
import PerfectCURL
import ObjectMapper

/// Github API Client in order to access Github API Endpoints
enum GithubAPIClient {
    /// Retrieve zen
    case zen
    /// Retrieve user info for given username
    case user(name: String)
    /// Retrieve repositories for user name
    case repositories(userName: String)
}

// MARK: APIClient
extension GithubAPIClient: APIClient {
    
    var baseURL: String {
        return "https://api.github.com/"
    }
    
    var path: String {
        switch self {
        case .zen:
            return "zen"
        case .user(name: let name):
            return "users/\(name)"
        case .repositories(userName: let name):
            return "users/\(name)/repos"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .zen:
            return .get
        case .user:
            return .get
        case .repositories:
            return .get
        }
    }
    
    var headers: [HTTPRequestHeader.Name: String]? {
        return [.userAgent: "PerfectAPIClient"]
    }
    
    var payload: BaseMappable? {
        // No request payload needed
        return nil
    }
    
    var options: [CURLRequest.Option]? {
        // No further options needed
        return nil
    }
    
    var mockedResult: APIClientResult<APIClientResponse>? {
        let request = APIClientRequest(apiClient: self)
        switch self {
        case .zen:
            let response = APIClientResponse(url: self.getRequestURL(), status: .ok, payload: "Some zen for you my friend", request: request)
            return .success(response)
        case .user:
            guard let userJSON = User(name: "Sven Tiigi", type: "user").toJSONString() else {
                return nil
            }
            let response = APIClientResponse(url: self.getRequestURL(), status: .ok, payload: userJSON, request: request)
            return .success(response)
        case .repositories:
            var repository = Repository()
            repository.name = "PerfectAPIClient"
            repository.fullName = "SvenTiigi/PerfectAPIClient"
            guard let repositoriesJSON = [repository].toJSONString() else {
                return nil
            }
            let response = APIClientResponse(url: self.getRequestURL(), status: .ok, payload: repositoriesJSON, request: request)
            return .success(response)
        }
    }
    
    func willPerformRequest(request: APIClientRequest) {
        print("Github API Client \(self.rawValue) will perform request \(request)")
    }
    
    func didRetrieveResponse(request: APIClientRequest, result: APIClientResult<APIClientResponse>) {
        print("Github API Client \(self.rawValue) did retrieve response for request: \(request) and result: \(result)")
    }
    
}

// MARK: RawRepresentable

extension GithubAPIClient: RawRepresentable {
    
    /// Associated type RawValue as String
    typealias RawValue = String
    
    /// RawRepresentable initializer. Which always returns nil
    ///
    /// - Parameters:
    ///   - rawValue: The rawValue
    init?(rawValue: String) {
        // Returning nil to avoid constructing enum with String
        return nil
    }
    
    /// The enumeration name as String
    var rawValue: RawValue {
        // Retrieve label via Mirror for Enum with associcated value
        guard let label = Mirror(reflecting: self).children.first?.label else {
            // Return String describing self enumeration with no asscoiated value
            return String(describing: self)
        }
        // Return label
        return label
    }
    
}

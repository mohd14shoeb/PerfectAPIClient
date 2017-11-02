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
}

// MARK: APIClient

extension GithubAPIClient: APIClient {
    
    public static let test = ""
    
    var baseURL: String {
        return "https://api.github.com/"
    }
    
    var path: String {
        switch self {
        case .zen:
            return "zen"
        case .user(name: let name):
            return "users/\(name)"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .zen:
            return .get
        case .user:
            return .get
        }
    }
    
    var authenticationHeaders: [String : String]? {
        // No authentication headers needed
        return nil
    }
    
    var headers: [String : String]? {
        return ["User-Agent": "PerfectAPIClient"]
    }
    
    var requestPayload: BaseMappable? {
        // No request payload needed
        return nil
    }
    
    var options: [CURLRequest.Option]? {
        // No further options needed
        return nil
    }
    
    var mockResponseResult: APIClientResult<APIClientResponse>? {
        switch self {
        case .zen:
            let response = APIClientResponse(url: self.getRequestURL(), status: .ok, payload: "Some zen for you my friend")
            return .success(response)
        case .user:
            guard let userJSON = User(name: "Sven Tiigi", type: "user").toJSONString() else {
                return .failure("Unable to setup mock data for user endpoint")
            }
            let response = APIClientResponse(url: self.getRequestURL(), status: .ok, payload: userJSON)
            return .success(response)
        }
    }
    
    func willPerformRequest(url: String, options: [CURLRequest.Option]) {
        print("Github API Client \(self.rawValue) will perform request \(url) with options: \(options)")
    }
    
    func didRetrieveResponse(url: String, options: [CURLRequest.Option], result: APIClientResult<APIClientResponse>) {
        print("Github API Client \(self.rawValue) did retrieve response for request \(url) with options: \(options) and result: \(result)")
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

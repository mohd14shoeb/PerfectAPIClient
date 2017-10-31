//
//  JSONPlaceholderAPI.swift
//  PerfectAPIClientTests
//
//  Created by Sven Tiigi on 28.10.17.
//

@testable import PerfectAPIClient
import PerfectHTTP
import PerfectCURL
import ObjectMapper

/// JSONPlaceholder API Client in order to access JSONPlaceholder API Endpoints
enum JSONPlaceholderAPIClient {
    /// Create a post
    case createPost(Post)
    /// An unavailable endpoint
    case mockedEndpoint
}

// MARK: APIClient

extension JSONPlaceholderAPIClient: APIClient {
    
    var baseURL: String {
        return "https://jsonplaceholder.typicode.com"
    }
    
    var path: String {
        switch self {
        case .createPost:
            return "/posts"
        case .mockedEndpoint:
            return "invalidEndpoint"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .createPost:
            return .post
        case .mockedEndpoint:
            return .get
        }
    }
    
    var authenticationHeaders: [String : String]? {
        // No authentication headers needed
        return nil
    }
    
    var headers: [String : String]? {
        // No headers needed
        return nil
    }
    
    var requestPayload: BaseMappable? {
        // Check if endpoint is createPost
        if case .createPost(let post) = self {
            // Return post object
            return post
        } else {
            // Else return nil
            return nil
        }
    }
    
    var options: [CURLRequest.Option]? {
        switch self {
        case .createPost:
            // Return custom timeout
            return [.timeout(15)]
        default:
            return nil
        }
    }
    
    var mockResponseResult: APIClientResult<APIClientResponse>? {
        switch self {
        case .mockedEndpoint:
            guard let postJSON = Post(title: "I'm a mocked Post", body: "Just for unit tests").toJSONString() else {
                return .failure("Unable to construct mocked Post JSON for unit tests")
            }
            let response = APIClientResponse(url: self.getRequestURL(), status: .ok, payload: postJSON, headers: ["UnitTest": "Rocks with PerfectAPIClient"])
            return .success(response)
        default:
            return nil
        }
    }
    
}

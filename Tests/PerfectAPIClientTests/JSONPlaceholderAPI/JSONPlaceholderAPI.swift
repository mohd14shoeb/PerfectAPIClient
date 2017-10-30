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
    case invalidEndpoint
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
        case .invalidEndpoint:
            return "invalidEndpoint"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .createPost:
            return .post
        case .invalidEndpoint:
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
        // No further options needed
        return nil
    }
    
    var mockResponseResult: APIClientResult<CURLResponse>? {
        return nil
    }

    func willPerformRequest(url: String, options: [CURLRequest.Option]) {
        print("JSONPlaceholder API Client will perform request \(url) with options: \(options)")
    }
    
    func didRetrieveResponse(url: String, options: [CURLRequest.Option], result: APIClientResult<CURLResponse>) {
        print("JSONPlaceholder API Client did retrieve response for request \(url) with options: \(options) and result: \(result)")
    }
    
}

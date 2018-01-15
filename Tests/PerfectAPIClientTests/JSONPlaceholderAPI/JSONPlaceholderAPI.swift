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
        return "https://jsonplaceholder.typicode.com/"
    }
    
    var path: String {
        switch self {
        case .createPost:
            return "posts"
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

    var headers: [HTTPRequestHeader.Name : String]? {
        // No headers needed
        return nil
    }
    
    var payload: BaseMappable? {
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
        // Return custom timeout
        return [.timeout(15)]
    }
    
    var mockedResult: APIClientResult<APIClientResponse>? {
        return nil
    }
    
}

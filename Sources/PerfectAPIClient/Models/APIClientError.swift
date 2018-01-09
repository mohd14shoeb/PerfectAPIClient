//
//  APIClientError.swift
//  PerfectAPIClient
//
//  Created by Sven Tiigi on 09.01.18.
//

/// APIClient Error
///
/// - failed: The APIClient failed
public enum APIClientError: Error {
    /// APIClient failed with reason and response
    case failed(
        reason: String,
        response: APIClientResponse
    )
    /// The connection failed
    case connectionFailed(
        error: Error,
        request: APIClientRequest
    )
    
    /// The localized APIClientError Description
    public var localizedDescription: String {
        switch self {
        case .failed(reason: let reason, response: let response):
            return "\(reason) | Response: \(response)"
        case .connectionFailed(error: let error, request: let request):
            return "\(error.localizedDescription) | Request: \(request)"
        }
    }
}

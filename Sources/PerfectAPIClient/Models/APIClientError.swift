//
//  APIClientError.swift
//  PerfectAPIClient
//
//  Created by Sven Tiigi on 09.01.18.
//


/// APIClientError
///
/// - mappingFailed: The mapping failed
/// - badResponseStatus: Retrieved bad response status
/// - connectionFailed: The connection failed
public enum APIClientError: Error {
    
    /// APIClient failed on mapping
    case mappingFailed(
        reason: String,
        response: APIClientResponse
    )
    
    /// APIClient did retrieved bad response status
    case badResponseStatus(
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
        case .mappingFailed(reason: let reason, response: let response):
            return "\(reason) | Response: \(response)"
        case .badResponseStatus(response: let response):
            return "Retrieved bad response code: \(response.status.code) | Response: \(response)"
        case .connectionFailed(error: let error, request: let request):
            return "\(error.localizedDescription) | Request: \(request)"
        }
    }
    
}

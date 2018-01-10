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
public enum APIClientError {
    
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
 
}

// MARK: Error Extension

extension APIClientError: Error {
    
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

// MARK: Analysis Extension

public extension APIClientError {
    
    /// Perform APIClientError Analysis
    ///
    /// - Parameters:
    ///   - mappingFailed: Invoked when error is mappingFailed
    ///   - badResponseStatus: Invoked when error is badResponseStatus
    ///   - connectionFailed: Invoked when error is connectionFailed
    func analysis(mappingFailed: ((String, APIClientResponse) -> Void)?,
                  badResponseStatus: ((APIClientResponse) -> Void)?,
                  connectionFailed: ((Error, APIClientRequest) -> Void)?) {
        // Switch on self
        switch self {
        case .mappingFailed(reason: let reason, response: let response):
            guard let mappingFailed = mappingFailed else {
                return
            }
            mappingFailed(reason, response)
        case .badResponseStatus(response: let response):
            guard let badResponseStatus = badResponseStatus else {
                return
            }
            badResponseStatus(response)
        case .connectionFailed(error: let error, request: let request):
            guard let connectionFailed = connectionFailed else {
                return
            }
            connectionFailed(error, request)
        }
    }
    
}

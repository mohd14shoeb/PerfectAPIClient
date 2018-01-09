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
}

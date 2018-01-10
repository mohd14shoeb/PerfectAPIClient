//
//  APIClientEnvironmentMode.swift
//  PerfectAPIClient
//
//  Created by Sven Tiigi on 10.01.18.
//

/// The APIClientEnvironmentMode
public enum APIClientEnvironmentMode {
    /// The standard mode performs real network request
    case standard
    /// Test will use mockResponseResult data if available
    case test
}

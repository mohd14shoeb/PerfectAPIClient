//
//  APIClientEnvironment.swift
//  PerfectAPIClient
//
//  Created by Sven Tiigi on 10.01.18.
//

/// The APIClientEnvironment specifies the environment for an APIClient
///
/// - `default`: The default environment. Performs real network requests
/// - tests: The tests environment. Use mockedResponseResult if available
public enum APIClientEnvironment {
    /// The default case specifies that the APIClient is running
    /// in a default environment where no mocked results should be used
    /// and real network requests should be executed
    case `default`
    /// The tests case specifies that the APIClient is running
    /// under Unit/Integration Tests Environment. If a mockedResponseResult
    /// is available this mocked result will be used in order to mock the network request
    case tests
}

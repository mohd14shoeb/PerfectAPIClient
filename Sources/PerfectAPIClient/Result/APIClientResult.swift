//
//  APIClientResult.swift
//  PerfectAPIClient
//
//  Created by Sven Tiigi on 28.10.17.
//

/// APIClientResult enumeration represents the result of an APIClient request
///
/// - success: The success case
/// - failure: The failure case
public enum APIClientResult<Value> {
    
    /// Success with generic as associated value
    case success(Value)
    
    /// Failure with error as associated value
    case failure(APIClientError)
    
}

// MARK: Analysis Extension

public extension APIClientResult {
    
    /// Perform result analysis with success and failure closure
    ///
    /// - Parameters:
    ///   - success: The success closure
    ///   - failure: The failure closure
    func analysis(success: ((Value) -> Void)?, failure: ((APIClientError) -> Void)?) {
        // Switch on self
        switch self {
        case .success(let value):
            // Unwrap success closure
            guard let success = success else {
                return
            }
            // Invoke closure with success value
            success(value)
        case .failure(let error):
            // Unwrap failure closure
            guard let failure = failure else {
                return
            }
            // Invoke closure with error
            failure(error)
        }
    }
    
}

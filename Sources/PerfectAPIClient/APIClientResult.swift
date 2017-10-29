//
//  APIClientResult.swift
//  PerfectAPIClient
//
//  Created by Sven Tiigi on 28.10.17.
//

/**
     APIClientResult enumeration represents
     the success failure case for an API response.
     The success case is defined by a generic.
     The failure case is defined by an error.
 */
public enum APIClientResult<Value> {
    
    /// Success
    case success(Value)
    
    /// Failure
    case failure(Error)
    
    /// Analysis result with given closures
    public func analysis(success: ((Value) -> Void)?, failure: ((Error) -> Void)?) {
        // Switch self
        switch self {
        case .success(let value):
            // Success verify closure
            guard let success = success else { return }
            // Invoke closure with success value
            success(value)
        case .failure(let error):
            // Failure verify closure
            guard let failure = failure else { return }
            // Invoke closure with error
            failure(error)
        }
    }
    
}

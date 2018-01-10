//
//  APIClientEnvironment.swift
//  PerfectAPIClient
//
//  Created by Sven Tiigi on 10.01.18.
//

/// The APIClientEnvironment Singleton
/// in order to define custom environment variables
public class APIClientEnvironment {
    
    /// Shared instance
    public static let shared = APIClientEnvironment()
    
    /// The mode
    public var mode: APIClientEnvironmentMode
    
    /// Private initializer
    private init() {
        // Set standard mode
        self.mode = .standard
    }
    
    /// Check if mode is equal to a given mode
    ///
    /// - Parameter mode: The mode to check
    /// - Returns: Boolean if current mode matches with passed mode
    public func isMode(_ mode: APIClientEnvironmentMode) -> Bool {
        return self.mode == mode
    }
    
}

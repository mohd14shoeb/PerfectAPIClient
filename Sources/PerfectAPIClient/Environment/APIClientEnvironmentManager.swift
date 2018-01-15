//
//  APIClientEnvironmentManager.swift
//  PerfectAPIClient
//
//  Created by Sven Tiigi on 10.01.18.
//

/// The APIClientEnvironmentManager Singleton holds the environment states
class APIClientEnvironmentManager {
    
    /// Shared instance
    static let shared = APIClientEnvironmentManager()
    
    /// The APIClient Environments
    var clientEnvironment: [String: APIClientEnvironment] = [:]
    
    /// Private initializer
    private init() {
        // Initialize Dictionary
        self.clientEnvironment = [:]
    }
    
    /// Set the environment for an APIClient
    ///
    /// - Parameters:
    ///   - mode: The environment
    ///   - apiClient: The APIClient
    func set<T: APIClient>(_ mode: APIClientEnvironment, forAPIClient apiClient: T.Type) {
        // Retrieve SubjectTypeName from APIClient
        let name = self.getSubjectTypeName(apiClient)
        // Set the APIClient enviroment
        self.clientEnvironment[name] = mode
    }
    
    /// Retrieve the environment for an APIClient
    ///
    /// - Parameter apiClient: The APIClient
    /// - Returns: The environment. If no environment has been set default value will be returned
    func get<T: APIClient>(forAPIClient apiClient: T.Type) -> APIClientEnvironment {
        // Retrieve SubjectTypeName from APIClient
        let name = self.getSubjectTypeName(apiClient)
        // Unwrap environment mode for APIClient name
        guard let mode = self.clientEnvironment[name] else {
            // No mode has been specified return default value
            return .default
        }
        // Return the APIClient environment
        return mode
    }
    
    /// Retrieve SubjectType name of an APIClient
    ///
    /// - Parameter apiClient: The APIClient
    /// - Returns: The SubjectType name string
    private func getSubjectTypeName<T: APIClient>(_ apiClient: T.Type) -> String {
        // Initialize APIClient Mirror
        let apiClientTypeMirror = Mirror(reflecting: apiClient)
        // Initialize String with subjectType mirror
        let name = String(describing: apiClientTypeMirror.subjectType)
        // Return the SubjectTypeName
        return name
    }
    
}

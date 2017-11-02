//
//  SwiftEnvExtension.swift
//  PerfectAPIClient
//
//  Created by Sven Tiigi on 30.10.17.
//

import SwiftEnv

extension SwiftEnv {
    
    /// The PerfectAPIClient unit tests environment variable identifier
    private static let apiClientUnitTestIdentifier = "PerfectAPIClientUnitTestCase"
    
    /// Idenfity if the current runtime for PerfectAPIClient is under unit test conditions
    static var isRunningAPIClientUnitTests: Bool {
        set {
            // Set if newValue is true otherwise set nil
            SwiftEnv()[apiClientUnitTestIdentifier] = newValue ? String(newValue) : nil
        }
        get {
            // Check if unit test environment variable is not nil
            return SwiftEnv()[apiClientUnitTestIdentifier] != nil
        }
    }
    
}

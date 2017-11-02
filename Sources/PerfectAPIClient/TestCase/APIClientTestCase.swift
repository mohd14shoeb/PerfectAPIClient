//
//  APIClientTestCase.swift
//  PerfectAPIClient
//
//  Created by Sven Tiigi on 02.11.17.
//

import XCTest
import SwiftEnv

/// Base APIClientTestCase for unit testing APIClient
public class APIClientTestCase: XCTestCase {
    
    /// Setup method called before the invocation of each test method in the class.
    public override func setUp() {
        super.setUp()
        // Set isRunning APIClient unit tests to true
        SwiftEnv.isRunningAPIClientUnitTests = true
    }
    
    /// Teardown method called after the invocation of each test method in the class.
    public override func tearDown() {
        super.tearDown()
        // Set isRunning APIClient unit tests to false
        SwiftEnv.isRunningAPIClientUnitTests = false
    }
    
}

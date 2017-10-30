//
//  ProcessInfoExtension.swift
//  PerfectAPIClient
//
//  Created by Sven Tiigi on 30.10.17.
//

import Foundation

extension ProcessInfo {

    /// Idenfity if the current runtime is under unit test conditions
    static var isRunningTests: Bool {
        return ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
    }
    
}

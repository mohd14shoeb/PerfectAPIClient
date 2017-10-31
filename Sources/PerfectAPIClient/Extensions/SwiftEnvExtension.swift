//
//  SwiftEnvExtension.swift
//  PerfectAPIClient
//
//  Created by Sven Tiigi on 30.10.17.
//

import SwiftEnv

extension SwiftEnv {
    
    /// Idenfity if the current runtime is under unit test conditions
    static var isRunningUnitTests: Bool {
        return SwiftEnv()["XCTestConfigurationFilePath"] != nil
    }
    
}

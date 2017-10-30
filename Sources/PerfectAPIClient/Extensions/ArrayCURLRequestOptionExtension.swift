//
//  ArrayCURLRequestOptionExtension.swift
//  PerfectAPIClient
//
//  Created by Sven Tiigi on 28.10.17.
//

import PerfectCURL
import Foundation

extension Array where Element == CURLRequest.Option {
    
    /// Add HTTP Headers
    ///
    /// - Parameter headers: The HTTP headers
    public mutating func add(httpHeaders headers: [String: String]?) {
        // Unwrap headers parameter
        guard let headers = headers else {
            // Headers is nil return out of function
            return
        }
        // Append HTTP Header for each key value pair
        headers.forEach { (key: String, value: String) in
            self.append(
                .addHeader(CURLRequest.Header.Name.custom(name: key), value)
            )
        }
    }
    
}

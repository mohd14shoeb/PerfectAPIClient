//
//  ArrayCURLRequestOptionExtension.swift
//  PerfectAPIClient
//
//  Created by Sven Tiigi on 28.10.17.
//

import PerfectCURL
import Foundation

/// Array Extension where Element is CURLRequest.Option Type
extension Array where Element == CURLRequest.Option {
    
    /// Add HTTP Headers
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

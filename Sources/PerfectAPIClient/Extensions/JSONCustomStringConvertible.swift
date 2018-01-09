//
//  JSONCustomStringConvertible.swift
//  PerfectAPIClient
//
//  Created by Sven Tiigi on 09.01.18.
//

import Foundation

/// Extended CustomStringConvertible to return pretty printed JSON
/// as textual representation of this instance.
public protocol JSONCustomStringConvertible: CustomStringConvertible {
    
    /// A JSON representation of this instance
    var json: [String: Any] { get }
    
}

// MARK: Default Implementation

extension JSONCustomStringConvertible {
    
    /// A textual representation of this instance.
    public var description: String {
        // Initialize empty JSON string
        let emptyJSON = "{}"
        // Check if JSON is valid JSON Object
        if !JSONSerialization.isValidJSONObject(self.json) {
            return emptyJSON
        }
        // Try to construct pretty printed JSON data from JSON
        guard let jsonData = try? JSONSerialization.data(withJSONObject: self.json, options: [.prettyPrinted]) else {
            // JSONSerialization failed return empty JSON string
            return emptyJSON
        }
        // Try to construct a String from jsonData with UTF-8 encoding
        guard let json = String(data: jsonData, encoding: .utf8) else {
            // Return empty JSON string
            return emptyJSON
        }
        // Return the response JSON description as String
        return json
    }
    
}

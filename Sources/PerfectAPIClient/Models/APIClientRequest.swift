//
//  APIClientRequest.swift
//  PerfectAPIClient
//
//  Created by Sven Tiigi on 09.01.18.
//

import Foundation
import PerfectCURL
import PerfectHTTP
import ObjectMapper

/// APIClientRequest represents an API request
public struct APIClientRequest {
    
    /// The url
    public var url: String
    
    /// The HTTP method
    public var method: HTTPMethod
    
    /// The request options
    public var options: [CURLRequest.Option]
    
    /// The payload
    public var payload: BaseMappable?
    
    /// Initializer
    ///
    /// - Parameters:
    ///   - url: The url
    ///   - method: The HTTP method
    ///   - options: The request options
    ///   - payload: The optional payload
    public init(url: String, method: HTTPMethod,
                options: [CURLRequest.Option], payload: BaseMappable? = nil) {
        self.url = url
        self.method = method
        self.options = options
        self.payload = payload
    }
    
    /// Initializer with APIClient
    ///
    /// - Parameter apiClient: The APIClient
    public init(apiClient: APIClient) {
        // Setup CURL Options with default options
        var options: [CURLRequest.Option] = [
            .httpMethod(apiClient.method)
        ]
        // Check if a request payload object is available
        if let payloadString = apiClient.requestPayload?.toJSONString() {
            // Append payload as json encoded string
            options.append(.postString(payloadString))
            // Append HTTP header content type JSON
            options.append(.addHeader(.contentType, "application/json"))
        }
        // Check if additional options are available
        if let apiOptions = apiClient.options {
            // Append apiOptions
            options.append(contentsOf: apiOptions)
        }
        // Unwrap HTTP Headers
        if let headers = apiClient.headers {
            // Add HTTP Headers
            options.append(.addHeaders(headers.map {($0, $1)}))
        }
        // Initialize
        self.init(
            url: apiClient.getRequestURL(),
            method: apiClient.method,
            options: options,
            payload: apiClient.requestPayload
        )
    }
    
}

// MARK: JSONCustomStringConvertible Extension

extension APIClientRequest: JSONCustomStringConvertible {
    
    /// A JSON representation of this instance
    public var json: [String: Any] {
        var requestJSON: [String: Any] = [
            "url": self.url,
            "method": self.method.description,
            "options": self.options.map { "\($0)" }
        ]
        if let payloadJSON = self.payload?.toJSONString(prettyPrint: true) {
            requestJSON["payload"] = payloadJSON
        }
        return requestJSON
    }
    
}

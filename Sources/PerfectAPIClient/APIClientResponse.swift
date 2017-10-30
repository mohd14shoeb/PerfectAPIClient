//
//  APIClientResponse.swift
//  PerfectAPIClient
//
//  Created by Sven Tiigi on 30.10.17.
//

import Foundation
import PerfectCURL
import PerfectHTTP
import ObjectMapper

/// APIClientResponse represents an API response
public struct APIClientResponse {
    
    /// The request url
    public let url: String
    
    /// The response status
    public let status: HTTPResponseStatus
    
    /// The payload
    public let payload: String
    
    /// Indicating if the response is successful (Status code: 200 - 299)
    public var isSuccessful: Bool {
        return 200 ... 299 ~= self.status.code
    }
    
    /// The curlResponse
    private var curlResponse: CURLResponse?
    
    /// The response HTTP headers
    private var headers: [String: String]?
    
    /// Initializer to construct custom APIClientResponse
    ///
    /// - Parameters:
    ///   - url: The request url
    ///   - status: The response status
    ///   - headers: The response HTTP header fields
    ///   - payload: The response payload
    public init(url: String, status: HTTPResponseStatus, payload: String, headers: [String: String]? = nil) {
        self.url = url
        self.status = status
        self.payload = payload
        self.headers = headers
    }
    
    /// Intitializer with CURLResponse
    ///
    /// - Parameter curlResponse: The CURLResponse
    public init(curlResponse: CURLResponse) {
        self.url = curlResponse.url
        self.status = HTTPResponseStatus.statusFrom(code: curlResponse.responseCode)
        self.payload = curlResponse.bodyString
        self.curlResponse = curlResponse
    }
    
    /// Get response HTTP header field
    ///
    /// - Parameter field: The HTTP header field
    /// - Returns: The HTTP header field value
    public func getHTTPHeader(field: String) -> String? {
        // Check if headers are available by direct initialization
        if let headers = self.headers {
            // Return HTTP header field
            return headers[field]
        } else if let curlResponse = self.curlResponse {
            // Return HTTP header field from CURLResponse
            return curlResponse.get(CURLResponse.Header.Name.custom(name: field))
        } else {
            // Unable to return HTTP header field
            return nil
        }
    }
    
    /// Retrieve Payload in JSON/Dictionary format
    ///
    /// - Returns: The payload as Dictionary
    public func getPayloadJSON() -> [String: Any]? {
        // Instantiate Data object from payload
        let data = Data(self.payload.utf8)
        // JSONSerialization payload data to Dictionary
        guard let json = (try? JSONSerialization.jsonObject(with: data, options: [])) as? [String: Any] else {
            // JSONSerialization fails return nil
            return nil
        }
        // Return JSON/Dictionary format
        return json
    }
    
    /// Retrieve Payload as Mappable Type
    ///
    /// - Parameters:
    ///   - type: The mappable type
    ///   - customPayload: Optional custom payload that should be used for mapping
    /// - Returns: The mapped object type
    public func getMappablePayload<T: BaseMappable>(type: T.Type, customPayload: [String: Any]? = nil) -> T? {
        // Check if a custom payload is available
        if let customPayload = customPayload {
            // Try to construct mappable with custom payload
            guard let mappable = type.init(JSON: customPayload) else {
                // Unable to construct return nil
                return nil
            }
            // Return mapped object
            return mappable
        } else {
            // Try to construct mappable with payload
            guard let mappable = type.init(JSONString: self.payload) else {
                // Unable to construct return nil
                return nil
            }
            // Return mapped object
            return mappable
        }
    }
    
}

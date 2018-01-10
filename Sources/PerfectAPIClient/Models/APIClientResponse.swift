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
    
    /// The url that has been requested
    public let url: String
    
    /// The response status
    public let status: HTTPResponseStatus
    
    /// The payload
    public var payload: String
    
    /// The request
    public var request: APIClientRequest
    
    /// Indicating if the response is successful (Status code: 200 - 299)
    public var isSuccessful: Bool {
        return 200 ... 299 ~= self.status.code
    }
    
    /// The curlResponse
    private var curlResponse: CURLResponse?
    
    /// The response HTTP headers set via initializer
    private var headers: [String: String]?
    
    /// Initializer to construct custom APIClientResponse
    ///
    /// - Parameters:
    ///   - url: The request url
    ///   - status: The response status
    ///   - headers: The response HTTP header fields
    ///   - payload: The response payload
    public init(url: String, status: HTTPResponseStatus, payload: String,
                request: APIClientRequest, headers: [String: String]? = nil) {
        self.url = url
        self.status = status
        self.payload = payload
        self.request = request
        self.headers = headers
    }
    
    /// Intitializer with CURLResponse
    ///
    /// - Parameter curlResponse: The CURLResponse
    public init(request: APIClientRequest, curlResponse: CURLResponse) {
        self.init(
            url: curlResponse.url,
            status: HTTPResponseStatus.statusFrom(code: curlResponse.responseCode),
            payload: curlResponse.bodyString,
            request: request
        )
        self.curlResponse = curlResponse
    }
    
    /// Get response HTTP header field
    ///
    /// - Parameter name: The HTTP header response name
    /// - Returns: The HTTP header field value
    public func getHTTPHeader(name: HTTPResponseHeader.Name) -> String? {
        // Check if headers are available by direct initialization
        if let headers = self.headers {
            // Return HTTP header field
            return headers[name.standardName]
        } else if let curlResponse = self.curlResponse {
            // Return HTTP header field from CURLResponse
            return curlResponse.get(name)
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
    
    /// Retrieve Payload in JSON Array format
    ///
    /// - Returns: The payload as Array
    public func getPayloadJSONArray() -> [[String: Any]]? {
        // Instantiate Data object from payload
        let data = Data(self.payload.utf8)
        // JSONSerialization payload data to Array
        guard let jsonArray = (try? JSONSerialization.jsonObject(with: data, options: [])) as? [[String: Any]] else {
            // JSONSerialization fails return nil
            return nil
        }
        // Return JSON Array
        return jsonArray
    }
    
    /// Retrieve Payload as Mappable Type
    ///
    /// - Parameters:
    ///   - type: The mappable type
    /// - Returns: The mapped object type
    public func getMappablePayload<T: BaseMappable>(type: T.Type) -> T? {
        // Try to construct mappable with payload
        guard let mappable = Mapper<T>().map(JSONString: self.payload) else {
            // Unable to construct return nil
            return nil
        }
        // Return mapped object
        return mappable
    }
    
    /// Retrieve Payload as Mappable Array Type
    ///
    /// - Parameter type: The mappable type
    /// - Returns: The mapped object array
    public func getMappablePayloadArray<T: BaseMappable>(type: T.Type) -> [T]? {
        // Try to construct mappables with payload
        guard let mappables = Mapper<T>().mapArray(JSONString: self.payload) else {
            // Unable to construct mappables return nil
            return nil
        }
        // Return mapped objects
        return mappables
    }
    
}

// MARK: CustomStringConvertible Extension

extension APIClientResponse: JSONCustomStringConvertible {
    
    /// A JSON representation of this instance
    public var json: [String: Any] {
        return [
            "url": self.url,
            "status": self.status.description,
            "payload": self.payload,
            "request": self.request.description,
            "isSuccessful": self.isSuccessful
        ]
    }
    
}

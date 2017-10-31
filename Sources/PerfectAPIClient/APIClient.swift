//
//  APIClient.swift
//  PerfectAPIClient
//
//  Created by Sven Tiigi on 28.10.17.
//

import PerfectHTTP
import PerfectCURL
import ObjectMapper

/// APIClient defines a protocol for accessing an API
public protocol APIClient {
    
    /// The base url
    var baseURL: String { get }
    
    /// The path to a specific endpoint
    var path: String { get }
    
    /// The HTTP method
    var method: HTTPMethod { get }
    
    /// The authentication HTTP headers
    var authenticationHeaders: [String: String]? { get }
    
    /// The HTTP headers
    var headers: [String: String]? { get }
    
    /// The request payload as BaseMappable
    var requestPayload: BaseMappable? { get }
    
    /// The additional request options
    var options: [CURLRequest.Option]? { get }
    
    /// The mock response result for unit testing
    var mockResponseResult: APIClientResult<APIClientResponse>? { get }
    
    /// Get request URL by concatenating baseURL and current path
    ///
    /// - Returns: The request URL
    func getRequestURL() -> String
    
    /// Modify the request url that is used to perform the API request
    ///
    /// - Parameter requestURL: The request url
    func modify(requestURL: inout String)
    
    /// Request the API endpoint to retrieve CURLResponse
    ///
    /// - Parameter completion: completion closure with APIClientResponse
    func request(completion: ((APIClientResult<APIClientResponse>) -> Void)?)
    
    /// Request the API endpoint to retrieve response as mappable object
    ///
    /// - Parameters:
    ///   - mappable: The mappable object type
    ///   - completion: The completion closure with APIClientresult
    func request<T: BaseMappable>(mappable: T.Type, completion: @escaping (APIClientResult<T>) -> Void)
    
    /// Modify response payload for mappable
    ///
    /// - Parameters:
    ///   - responseJSON: The response JSON
    ///   - mappable: The mappable object type that should be mapped to
    func modify(responseJSON: inout [String: Any], mappable: BaseMappable.Type)
    
    /// Will perform request to API endpoint
    ///
    /// - Parameters:
    ///   - url: The request url
    ///   - options: The supplied request options
    func willPerformRequest(url: String, options: [CURLRequest.Option])
    
    /// Did retrieve response after request has initiated
    ///
    /// - Parameters:
    ///   - url: The request url
    ///   - options: The supplied request options
    ///   - result: The APIClientResult
    func didRetrieveResponse(url: String, options: [CURLRequest.Option], result: APIClientResult<APIClientResponse>)
    
}
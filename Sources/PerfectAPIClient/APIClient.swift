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
    var mockResponseResult: APIClientResult<CURLResponse>? { get }
    
    /// Request the API endpoint to retrieve CURLResponse
    ///
    /// - Parameter completion: completion closure with APIClientResult
    func request(completion: ((APIClientResult<CURLResponse>) -> Void)?)
    
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
    /// - Returns: The updated response JSON as Dictionary
    func modify(responseJSON: [String: Any], mappable: BaseMappable.Type) -> [String: Any]
    
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
    func didRetrieveResponse(url: String, options: [CURLRequest.Option], result: APIClientResult<CURLResponse>)
    
}

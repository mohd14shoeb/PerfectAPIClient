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
    
    /// The HTTP headers
    var headers: [HTTPRequestHeader.Name: String]? { get }
    
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
    
    /// Request the API endpoint to retrieve response as mappable object array
    ///
    /// - Parameters:
    ///   - mappable: The mappable object type
    ///   - completion: The completion closure with APIClientResult
    func request<T: BaseMappable>(mappable: T.Type, completion: @escaping (APIClientResult<[T]>) -> Void)
    
    /// Modify response payload for mappable
    ///
    /// - Parameters:
    ///   - responseJSON: The response JSON
    ///   - mappable: The mappable object type that should be mapped to
    func modify(responseJSON: inout [String: Any], mappable: BaseMappable.Type)
    
    /// Modify response payload array for mappable
    ///
    /// - Parameters:
    ///   - responseJSONArray: The response JSON array
    ///   - mappable: The mappable object type that should be mapped to
    func modify(responseJSONArray: inout [[String: Any]], mappable: BaseMappable.Type)
    
    /// Indicating if the APIClient should return an error
    /// On a bad response code >= 300 and < 200
    func shouldFailOnBadResponseStatus() -> Bool
    
    /// Will perform request to API endpoint
    ///
    /// - Parameters:
    ///   - request: The APIClientRequest
    func willPerformRequest(request: APIClientRequest)
    
    /// Did retrieve response after request has initiated
    ///
    /// - Parameters:
    ///   - request: The APIClientRequest
    ///   - result: The APIClientResult
    func didRetrieveResponse(request: APIClientRequest, result: APIClientResult<APIClientResponse>)
    
}

//
//  APIClient.swift
//  PerfectAPIClient
//
//  Created by Sven Tiigi on 28.10.17.
//

import PerfectHTTP
import PerfectCURL
import ObjectMapper

/// APIClient defines a protocol for accessing an RESTful Webservice API
public protocol APIClient {
    
    /// The base url
    var baseURL: String { get }
    
    /// The path
    var path: String { get }
    
    /// The HTTP method
    var method: HTTPMethod { get }
    
    /// The authentication HTTP headers
    var authenticationHeaders: [String: String]? { get }
    
    /// The HTTP headers
    var headers: [String: String]? { get }
    
    /// The request payload
    var requestPayload: BaseMappable? { get }
    
    /// Request options
    var options: [CURLRequest.Option]? { get }
    
    /// Request the API to retrieve Response
    func request(completion: ((APIClientResult<CURLResponse>) -> Void)?)
    
    /// Request the API to retrieved mapped response
    func request<T: BaseMappable>(mappedResponseType: T.Type, completion: @escaping (APIClientResult<T>) -> Void)
    
    /// Modify Response Paylod
    func modifyResponse(payload: [String: Any]) -> [String: Any]
    
    /// Will perform request for url and request options
    func willPerformRequest(url: String, options: [CURLRequest.Option])
    
    /// Did retrieve response for url, request options and api response result
    func didRetrieveResponse(url: String, options: [CURLRequest.Option], result: APIClientResult<CURLResponse>)
    
}

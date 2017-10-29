//
//  APIClient.swift
//  PerfectAPIClient
//
//  Created by Sven Tiigi on 28.10.17.
//

import Foundation
import PerfectHTTP
import PerfectCURL
import ObjectMapper

// MARK: APIClient Protocol

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

// MARK: Default implementation

public extension APIClient {
    
    /// Request the API to retrieve Response
    func request(completion: ((APIClientResult<CURLResponse>) -> Void)?) {
        // Setup URL
        let url = self.getURL()
        // Setup CURL Options with default options
        var options: [CURLRequest.Option] = [
            .httpMethod(self.method),
            .failOnError
        ]
        // Check if additional options are available
        if let apiOptions = self.options {
            // Append apiOptions
            options.append(contentsOf: apiOptions)
        }
        // Check if a request payload object is available
        if let payloadString = self.requestPayload?.toJSONString() {
            // Append payload as json encoded string
            options.append(
                .postString(payloadString)
            )
        }
        // Add authentication HTTP Headers
        options.add(httpHeaders: self.authenticationHeaders)
        // Add HTTP Headers
        options.add(httpHeaders: self.headers)
        // Invoke will perform request
        self.willPerformRequest(url: url, options: options)
        // Perform request
        CURLRequest(url, options: options).perform { (curlResponse: () throws -> CURLResponse) in
            do {
                // Try to retrieve response
                let response = try curlResponse()
                // Invoke did retrieve response
                self.didRetrieveResponse(url: url, options: options, result: .success(response))
                // Check if a completion closure is supplied
                guard let completion = completion else {
                    return
                }
                // Invoke completion with response
                completion(.success(response))
            } catch {
                // Invoke did retrieve response
                self.didRetrieveResponse(url: url, options: options, result: .failure(error))
                // Check if a completion closure is supplied
                guard let completion = completion else {
                    return
                }
                // Error occured complete with failure
                completion(.failure(error))
            }
        }
    }
    
    /// Request the API with associated response type
    func request<T: BaseMappable>(mappedResponseType: T.Type, completion: @escaping (APIClientResult<T>) -> Void) {
        // Perform request to retrieve response
        self.request { (result: APIClientResult<CURLResponse>) in
            // Analysis request result
            result.analysis(success: { (response: CURLResponse) in
                // Retrieve body json
                let json = self.modifyResponse(payload: response.bodyJSON)
                // Try to map response via mapped response type
                guard let mappedResponse = mappedResponseType.init(JSON: json) else {
                    // Unable to map response
                    let error = MapError(key: nil, currentValue: nil, reason: "Unable to map response with type: \(mappedResponseType)")
                    completion(.failure(error))
                    // Return out of function
                    return
                }
                // Mapping succeded complete with success
                completion(.success(mappedResponse))
            }, failure: { (error: Error) in
                // Complete with error
                completion(.failure(error))
            })
        }
    }
    
    /// Modify Response Paylod
    func modifyResponse(payload: [String: Any]) -> [String: Any] {
        return payload
    }
    
    /// Will perform request for url and request options
    func willPerformRequest(url: String, options: [CURLRequest.Option]) {}
    
    /// Did retrieve response for url, request options and api response result
    func didRetrieveResponse(url: String, options: [CURLRequest.Option], result: APIClientResult<CURLResponse>) {}
    
}

// MARK: Private helper functions

fileprivate extension APIClient {
    
    /// Retrieve the URL by validating Slashes
    func getURL() -> String {
        // Initialize baseUrl
        var baseUrl = self.baseURL
        // Initialize path
        var path = self.path
        // Check if baseUrl last character is not slash
        if baseUrl.last != "/" {
            // Add a slash
            baseUrl += "/"
        }
        // Check if first character is slash
        if path.first == "/" {
            // Chop first character
            path = path.substring(from: path.index(path.startIndex, offsetBy: 1))
        }
        // Return url
        return baseUrl + path
    }
    
}

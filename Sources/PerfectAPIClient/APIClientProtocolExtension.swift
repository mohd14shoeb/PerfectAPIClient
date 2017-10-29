//
//  APIClientProtocolExtension.swift
//  PerfectAPIClient
//
//  Created by Sven Tiigi on 29.10.17.
//

import Foundation
import PerfectHTTP
import PerfectCURL
import ObjectMapper

// MARK: Default implementation

public extension APIClient {
    
    /// Request the API endpoint to retrieve CURLResponse
    ///
    /// - Parameter completion: completion closure with APIClientResult
    func request(completion: ((APIClientResult<CURLResponse>) -> Void)?) {
        // Get URL
        let url = self.getRequestURL()
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
            // Declare APIClientResult with CURLResponse
            let result: APIClientResult<CURLResponse>
            defer {
                // Defer didRetrieveResponse invocation
                self.didRetrieveResponse(url: url, options: options, result: result)
            }
            do {
                // Try to retrieve response
                let response = try curlResponse()
                // Set result with success and response object
                result = .success(response)
            } catch {
                // Set result with failure and error object
                result = .failure(error)
            }
            // Unwrap completion clousre
            guard let completion = completion else {
                // No completion closure return out of function
                return
            }
            // Invoke completion with result
            completion(result)
        }
    }
    
    /// Request the API endpoint to retrieve response as mappable object
    ///
    /// - Parameters:
    ///   - mappable: The mappable object type
    ///   - completion: The completion closure with APIClientresult
    func request<T: BaseMappable>(mappable: T.Type, completion: @escaping (APIClientResult<T>) -> Void) {
        // Perform request to retrieve response
        self.request { (result: APIClientResult<CURLResponse>) in
            // Analysis request result
            result.analysis(success: { (response: CURLResponse) in
                // Retrieve body json
                let json = self.modify(responseJSON: response.bodyJSON, mappable: mappable)
                // Try to map response via mapped response type
                guard let mappedResponse = mappable.init(JSON: json) else {
                    // Unable to map response
                    let error = MapError(key: nil, currentValue: nil, reason: "Unable to map response with type: \(mappable)")
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
    
    /// Modify response payload for mappable
    ///
    /// - Parameters:
    ///   - responseJSON: The response JSON
    ///   - mappable: The mappable object type that should be mapped to
    /// - Returns: The updated response JSON as Dictionary
    func modify(responseJSON: [String: Any], mappable: BaseMappable.Type) -> [String: Any] {
        return responseJSON
    }
    
    /// Will perform request to API endpoint
    ///
    /// - Parameters:
    ///   - url: The request url
    ///   - options: The supplied request options
    func willPerformRequest(url: String, options: [CURLRequest.Option]) {}
    
    /// Did retrieve response after request has initiated
    ///
    /// - Parameters:
    ///   - url: The request url
    ///   - options: The supplied request options
    ///   - result: The APIClientResult
    func didRetrieveResponse(url: String, options: [CURLRequest.Option], result: APIClientResult<CURLResponse>) {}
    
}

// MARK: Private helper functions

fileprivate extension APIClient {
    
    /// Get request URL by concatenating baseURL and current path with validation
    ///
    /// - Returns: The request URL
    func getRequestURL() -> String {
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

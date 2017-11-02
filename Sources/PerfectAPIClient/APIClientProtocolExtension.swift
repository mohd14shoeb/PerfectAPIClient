//
//  APIClientProtocolExtension.swift
//  PerfectAPIClient
//
//  Created by Sven Tiigi on 29.10.17.
//

import PerfectHTTP
import PerfectCURL
import ObjectMapper
import SwiftEnv

// MARK: Default implementation

public extension APIClient {
    
    /// Get request URL by concatenating baseURL and current path
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
            path = String(path.dropFirst())
        }
        // Return url
        return baseUrl + path
    }
    
    /// Modify the request url that is used to perform the API request
    ///
    /// - Parameter requestURL: The request url
    func modify(requestURL: inout String) {}
    
    /// Request the API endpoint to retrieve CURLResponse
    ///
    /// - Parameter completion: completion closure with APIClientResult
    func request(completion: ((APIClientResult<APIClientResponse>) -> Void)?) {
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
            options.append(.postString(payloadString))
            // Append HTTP header content type JSON
            options.append(.addHeader(.contentType, "application/json"))
        }
        // Add authentication HTTP Headers
        options.add(httpHeaders: self.authenticationHeaders)
        // Add HTTP Headers
        options.add(httpHeaders: self.headers)
        // Invoke will perform request
        self.willPerformRequest(url: url, options: options)
        // Perform API request with url and options and handle requestCompletion result
        self.performRequest(url: url, options: options) { (result: APIClientResult<APIClientResponse>) in
            // Invoke didRetrieveResponse with result
            self.didRetrieveResponse(url: url, options: options, result: result)
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
        self.request { (result: APIClientResult<APIClientResponse>) in
            // Analysis request result
            result.analysis(success: { (response: APIClientResponse) in
                // Unwrap payload JSON
                guard var json = response.getPayloadJSON() else {
                    // Payload isn't a valid JSON
                    completion(.failure("Response payload isn't a valid JSON"))
                    // Return out of function
                    return
                }
                // Invoke modify responseJSON
                self.modify(responseJSON: &json, mappable: mappable)
                // Try to map response via mapped response type
                guard let mappedResponse = mappable.init(JSON: json) else {
                    // Unable to map response
                    completion(.failure("Unable to map response with type: \(mappable)"))
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
    func modify(responseJSON: inout [String: Any], mappable: BaseMappable.Type) {}
    
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
    func didRetrieveResponse(url: String, options: [CURLRequest.Option], result: APIClientResult<APIClientResponse>) {}
    
}

// MARK: Perform Request

fileprivate extension APIClient {
    
    /// Perform API request which evaluates if a network request or a mocked response
    /// result should be returned via the request completion closure
    ///
    /// - Parameters:
    ///   - url: The request url
    ///   - options: The request options
    ///   - requestCompletion: The request completion closure after result has been retrieved
    func performRequest(url: String, options: [CURLRequest.Option], requestCompletion: @escaping (APIClientResult<APIClientResponse>) -> Void) {
        // Check if a mockedResponseResult object is available and runtime is under unit test conditions
        if let mockedResponseResult = self.mockResponseResult, SwiftEnv.isRunningAPIClientUnitTests {
            // Invoke requestCompletion with mockedResponseResult
            requestCompletion(mockedResponseResult)
        } else {
            // Perform network request
            CURLRequest(url, options: options).perform { (curlResponse: () throws -> CURLResponse) in
                do {
                    // Try to retrieve CURLResponse and construct APIClientResponse
                    let response = APIClientResponse(curlResponse: try curlResponse())
                    // Invoke requestCompletion with success case and APIClientResponse
                    requestCompletion(.success(response))
                } catch {
                    // Invoke requestCompletion with failure and error
                    requestCompletion(.failure(error))
                }
            }
        }
    }
    
}

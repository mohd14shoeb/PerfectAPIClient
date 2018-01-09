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
        // Initialize APIClientRequest for APIClient
        let request = APIClientRequest(apiClient: self)
        // Invoke will perform request
        self.willPerformRequest(request: request)
        // Perform API request with url and options and handle requestCompletion result
        self.performRequest(request) { (result: APIClientResult<APIClientResponse>) in
            // Invoke didRetrieveResponse with result
            self.didRetrieveResponse(request: request, result: result)
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
                    let error = APIClientError.mappingFailed(
                        reason: "Response payload isn't a valid JSON",
                        response: response
                    )
                    completion(.failure(error))
                    // Return out of function
                    return
                }
                // Invoke modify responseJSON
                self.modify(responseJSON: &json, mappable: mappable)
                // Try to map response via mapped response type
                guard let mappedResponse = Mapper<T>().map(JSON: json) else {
                    // Unable to map response
                    let error = APIClientError.mappingFailed(
                        reason: "Unable to map response for type: \(mappable)",
                        response: response
                    )
                    completion(.failure(error))
                    // Return out of function
                    return
                }
                // Mapping succeded complete with success
                completion(.success(mappedResponse))
            }, failure: { (error: APIClientError) in
                // Complete with error
                completion(.failure(error))
            })
        }
    }
    
    /// Request the API endpoint to retrieve response as mappable object array
    ///
    /// - Parameters:
    ///   - mappable: The mappable object type
    ///   - completion: The completion closure with APIClientResult
    func request<T: BaseMappable>(mappable: T.Type, completion: @escaping (APIClientResult<[T]>) -> Void) {
        // Perform request to retrieve response
        self.request { (result: APIClientResult<APIClientResponse>) in
            // Analysis request result
            result.analysis(success: { (response: APIClientResponse) in
                // Unwrap payload JSON
                guard var jsonArray = response.getPayloadJSONArray() else {
                    // Payload isn't a valid JSON
                    let error = APIClientError.mappingFailed(
                        reason: "Response payload isn't a valid JSON Array",
                        response: response
                    )
                    completion(.failure(error))
                    // Return out of function
                    return
                }
                // Invoke modify responseJSONArray
                self.modify(responseJSONArray: &jsonArray, mappable: mappable)
                // Map JSON Array to Mappable Object Array
                let mappedResponseArray = Mapper<T>().mapArray(JSONArray: jsonArray)
                // Check if ObjectMapper mapped the json array to given type
                if jsonArray.count != mappedResponseArray.count {
                    // Unable to map response
                    let error = APIClientError.mappingFailed(
                        reason: "Unable to map response array for type: \(mappable)",
                        response: response
                    )
                    completion(.failure(error))
                    // Return out of function
                    return
                }
                // Mapping succeded complete with success
                completion(.success(mappedResponseArray))
            }, failure: { (error: APIClientError) in
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
    
    /// Modify response payload array for mappable
    ///
    /// - Parameters:
    ///   - responseJSONArray: The response JSON array
    ///   - mappable: The mappable object type that should be mapped to
    func modify(responseJSONArray: inout [[String: Any]], mappable: BaseMappable.Type) {}
    
    /// Indicating if the APIClient should return an error
    /// On a bad response code >= 300 and < 200
    func shouldFailOnBadResponseStatus() -> Bool {
        // Default implementation return true
        return true
    }
    
    /// Will perform request to API endpoint
    ///
    /// - Parameters:
    ///   - request: The APIClientRequest
    func willPerformRequest(request: APIClientRequest) {}
    
    /// Did retrieve response after request has initiated
    ///
    /// - Parameters:
    ///   - request: The APIClientRequest
    ///   - result: The APIClientResult
    func didRetrieveResponse(request: APIClientRequest, result: APIClientResult<APIClientResponse>) {}
    
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
    func performRequest(_ request: APIClientRequest, requestCompletion: @escaping (APIClientResult<APIClientResponse>) -> Void) {
        // Check if a mockedResponseResult object is available and runtime is under unit test conditions
        if let mockedResponseResult = self.mockResponseResult, SwiftEnv.isRunningAPIClientUnitTests {
            // Invoke requestCompletion with mockedResponseResult
            requestCompletion(mockedResponseResult)
            // Return out of function
            return
        }
        // Perform network request for url and options
        CURLRequest(request.url, options: request.options).perform { (curlResponse: () throws -> CURLResponse) in
            do {
                // Try to retrieve CURLResponse and construct APIClientResponse
                let response = APIClientResponse(
                    request: request,
                    curlResponse: try curlResponse()
                )
                // Initialize result with success and response
                var result: APIClientResult<APIClientResponse> = .success(response)
                // Check if APIClient should fail on bad response status
                // and response isn't successful
                if self.shouldFailOnBadResponseStatus() && !response.isSuccessful {
                    // Initialize APIClientError
                    let error = APIClientError.badResponseStatus(response: response)
                    // Override result with failure
                    result = .failure(error)
                }
                // Invoke request completion with result
                requestCompletion(result)
            } catch {
                // Invoke requestCompletion with failure and error
                let connectionError = APIClientError.connectionFailed(error: error, request: request)
                requestCompletion(.failure(connectionError))
            }
        }
    }
    
}

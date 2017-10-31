//
//  PerfectAPIClientTests.swift
//  PerfectAPIClientTests
//
//  Created by Sven Tiigi on 28.10.17.
//

import XCTest
import PerfectCURL
import SwiftEnv
@testable import PerfectAPIClient

class PerfectAPIClientTests: XCTestCase {
    
    /// Default Timeout
    private let timeout: TimeInterval = 15
    
    /// All tests
    static var allTests = [
        ("testSwiftEnvExtension", testSwiftEnvExtension),
        ("testMockedGithubZenRequest", testMockedGithubZenRequest),
        ("testNetworkGithubZenRequestWithoutCompletion", testNetworkGithubZenRequestWithoutCompletion),
        ("testNetworkGithubMappedUserRequest", testNetworkGithubMappedUserRequest),
        ("testNetworkJSONPlaceholderPostRequest", testNetworkJSONPlaceholderPostRequest),
        ("testMockedJSONPlacerHolderEndpoint", testMockedJSONPlacerHolderEndpoint)
    ]
    
    override func setUp() {
        super.setUp()
        self.continueAfterFailure = false
        SwiftEnv()["XCTestConfigurationFilePath"] = "true"
    }
    
    override func tearDown() {
        super.tearDown()
        SwiftEnv()["XCTestConfigurationFilePath"] = nil
    }
    
    func testSwiftEnvExtension() {
        XCTAssert(SwiftEnv.isRunningUnitTests)
    }
    
    func testMockedGithubZenRequest() {
        let expectation = self.expectation(description: #function)
        GithubAPIClient.zen.request { (result: APIClientResult<APIClientResponse>) in
            result.analysis(success: { (response: APIClientResponse) in
                XCTAssertEqual(response.payload, "Some zen for you my friend")
                expectation.fulfill()
            }, failure: { (error: Error) in
                XCTFail(error.localizedDescription)
            })
        }
        self.waitForExpectations(timeout: self.timeout, handler: nil)
    }
    
    func testNetworkGithubZenRequestWithoutCompletion() {
        GithubAPIClient.zen.request(completion: nil)
    }
    
    func testNetworkGithubMappedUserRequest() {
        let expectation = self.expectation(description: #function)
        GithubAPIClient.user(name: "sventiigi").request(mappable: User.self) { (result: APIClientResult<User>) in
            result.analysis(success: { (user: User) in
                XCTAssertEqual(user.name, "Sven Tiigi")
                XCTAssertEqual(user.type, "user")
                expectation.fulfill()
            }, failure: { (error: Error) in
                XCTFail(error.localizedDescription)
            })
        }
        self.waitForExpectations(timeout: self.timeout, handler: nil)
    }
    
    func testNetworkJSONPlaceholderPostRequest() {
        let expectation = self.expectation(description: #function)
        var post = Post()
        post.title = "Mr.Robot loves PerfectAPIClient"
        post.body = "Awesome body description"
        JSONPlaceholderAPIClient.createPost(post).request { (result: APIClientResult<APIClientResponse>) in
            result.analysis(success: { (response: APIClientResponse) in
                XCTAssert(!response.payload.isEmpty)
                expectation.fulfill()
            }, failure: nil)
        }
        self.waitForExpectations(timeout: self.timeout, handler: nil)
    }
    
    func testMockedJSONPlacerHolderEndpoint() {
        let expectation = self.expectation(description: #function)
        JSONPlaceholderAPIClient.mockedEndpoint.request { (result: APIClientResult<APIClientResponse>) in
            result.analysis(success: { (response: APIClientResponse) in
                XCTAssert(response.isSuccessful)
                guard let post = response.getMappablePayload(type: Post.self) else {
                    XCTFail("Expected to retrieve Payload as Post object")
                    return
                }
                XCTAssertEqual(post.title, "I'm a mocked Post")
                guard let unitTestHTTPHeader = response.getHTTPHeader(field: "UnitTest") else {
                    XCTFail("Expected to have a UnitTest HTTP header field")
                    return
                }
                XCTAssertEqual(unitTestHTTPHeader, "Rocks with PerfectAPIClient")
                expectation.fulfill()
            }, failure: { (error: Error) in
                XCTFail(error.localizedDescription)
            })
        }
        self.waitForExpectations(timeout: self.timeout, handler: nil)
    }

}

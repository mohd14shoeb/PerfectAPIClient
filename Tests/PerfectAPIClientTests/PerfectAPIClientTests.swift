//
//  PerfectAPIClientTests.swift
//  PerfectAPIClientTests
//
//  Created by Sven Tiigi on 28.10.17.
//

import XCTest
import PerfectCURL
@testable import PerfectAPIClient

class PerfectAPIClientTests: XCTestCase {
    
    /// Default Timeout
    private let timeout: TimeInterval = 15
    
    /// All tests
    static var allTests = [
        ("testGithubZenRequest", testGithubZenRequest),
        ("testGithubZenRequestWithoutCompletion", testGithubZenRequestWithoutCompletion),
        ("testGithubMappedUserRequest", testGithubMappedUserRequest),
        ("testJSONPlaceholderPostRequest", testJSONPlaceholderPostRequest),
        ("testJSONPlaceholderInvalidEndpointRequest", testJSONPlaceholderInvalidEndpointRequest)
    ]
    
    override func setUp() {
        self.continueAfterFailure = false
    }
    
    func testGithubZenRequest() {
        let expectation = self.expectation(description: #function)
        GithubAPIClient.zen.request { (result: APIClientResult<CURLResponse>) in
            result.analysis(success: { (response: CURLResponse) in
                XCTAssert(!response.bodyString.isEmpty)
                expectation.fulfill()
            }, failure: { (error: Error) in
                XCTFail(error.localizedDescription)
            })
        }
        self.wait(for: [expectation], timeout: self.timeout)
    }
    
    func testGithubZenRequestWithoutCompletion() {
        GithubAPIClient.zen.request(completion: nil)
    }
    
    func testGithubMappedUserRequest() {
        let expectation = self.expectation(description: #function)
        GithubAPIClient.user(name: "sventiigi").request(mappedResponseType: User.self) { (result: APIClientResult<User>) in
            result.analysis(success: { (user: User) in
                XCTAssertNotNil(user.id)
                XCTAssertNotNil(user.name)
                XCTAssertNotNil(user.type)
                expectation.fulfill()
            }, failure: { (error: Error) in
                XCTFail(error.localizedDescription)
            })
        }
        self.wait(for: [expectation], timeout: self.timeout)
    }
    
    func testJSONPlaceholderPostRequest() {
        let expectation = self.expectation(description: #function)
        var post = Post()
        post.id = 42
        post.userId = 7
        post.title = "Mr.Robot loves PerfectAPIClient"
        post.body = "Awesome body description"
        JSONPlaceholderAPIClient.createPost(post).request { (result: APIClientResult<CURLResponse>) in
            result.analysis(success: { (response: CURLResponse) in
                XCTAssert(!response.bodyString.isEmpty)
                expectation.fulfill()
            }, failure: nil)
        }
        self.wait(for: [expectation], timeout: self.timeout)
    }
    
    func testJSONPlaceholderInvalidEndpointRequest() {
        let expectation = self.expectation(description: #function)
        JSONPlaceholderAPIClient.invalidEndpoint.request { (result: APIClientResult<CURLResponse>) in
            result.analysis(success: nil, failure: { (_) in
                expectation.fulfill()
            })
        }
        self.wait(for: [expectation], timeout: self.timeout)
    }

}

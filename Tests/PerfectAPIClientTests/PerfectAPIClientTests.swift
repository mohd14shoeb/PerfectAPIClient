//
//  PerfectAPIClientTests.swift
//  PerfectAPIClientTests
//
//  Created by Sven Tiigi on 28.10.17.
//

import XCTest
import SwiftEnv
@testable import PerfectAPIClient

class PerfectAPIClientTests: APIClientTestCase {
    
    // MARK: Properties
    
    /// Default Timeout
    private let timeout: TimeInterval = 15
    
    /// All tests
    static var allTests = [
        ("testSwiftEnvUnitTestExtension", testSwiftEnvUnitTestExtension),
        ("testGithubZenEndpoint", testGithubZenEndpoint),
        ("testGithubUserEndpoint", testGithubUserEndpoint),
        ("testJSONPlaceholderPostEndpoint", testJSONPlaceholderPostEndpoint),
        ("testJSONPlacerHolderInvalidEndpoint", testJSONPlacerHolderInvalidEndpoint)
    ]
    
    // MARK: Setup
    
    /// Setup method called before the invocation of each test method in the class.
    override func setUp() {
        super.setUp()
        // Disable continute after failure
        self.continueAfterFailure = false
    }
    
    // MARK: Private test helper function
    
    /// Perform test with expectation
    ///
    /// - Parameters:
    ///   - name: The expectation name
    ///   - execution: The test execution
    private func performTest(_ expectationName: String, _ execution: (XCTestExpectation) -> Void) {
        // Create expectation with function name
        let expectation = self.expectation(description: expectationName)
        // Perform test execution with expectation
        execution(expectation)
        // Wait for expectation been fulfilled with default timeout
        self.waitForExpectations(timeout: self.timeout, handler: nil)
    }
    
    // MARK: Extension Tests
    
    /// Test SwiftEnv UnitTest static property extension
    func testSwiftEnvUnitTestExtension() {
        XCTAssert(SwiftEnv.isRunningAPIClientUnitTests)
    }
    
    // MARK: Github Tests [Mocked]
    
    func testGithubZenEndpoint() {
        self.performTest(#function) { (expectation) in
            GithubAPIClient.zen.request { (result: APIClientResult<APIClientResponse>) in
                result.analysis(success: { (response: APIClientResponse) in
                    XCTAssertEqual(response.payload, "Some zen for you my friend")
                    expectation.fulfill()
                }, failure: { (error: Error) in
                    XCTFail(error.localizedDescription)
                })
            }
        }
    }
    
    func testGithubUserEndpoint() {
        self.performTest(#function) { (expectation) in
            GithubAPIClient.user(name: "sventiigi").request(mappable: User.self) { (result: APIClientResult<User>) in
                result.analysis(success: { (user: User) in
                    XCTAssertEqual(user.name, "Sven Tiigi")
                    XCTAssertEqual(user.type, "user")
                    expectation.fulfill()
                }, failure: { (error: Error) in
                    XCTFail(error.localizedDescription)
                })
            }
        }
    }
    
    // MARK: JSONPlaceholder Tests [Network]
    
    func testJSONPlaceholderPostEndpoint() {
        self.performTest(#function) { (expectation) in
            let post = Post(title: "Mr.Robot loves PerfectAPIClient", body: "Awesome body description")
            JSONPlaceholderAPIClient.createPost(post).request { (result: APIClientResult<APIClientResponse>) in
                result.analysis(success: { (response: APIClientResponse) in
                    guard let responsePost = response.getMappablePayload(type: Post.self) else {
                        XCTFail("Response Payload isn't a valid Post JSON")
                        return
                    }
                    XCTAssertEqual(post, responsePost)
                    expectation.fulfill()
                }, failure: { (error: Error) in
                    XCTFail(error.localizedDescription)
                })
            }
        }
    }
    
    func testJSONPlacerHolderInvalidEndpoint() {
        self.performTest(#function) { (expectation) in
            JSONPlaceholderAPIClient.invalidEndpoint.request { (result: APIClientResult<APIClientResponse>) in
                result.analysis(success: { (_) in
                    XCTFail("Invalid Endpoint shouldn't succeed")
                }, failure: { (_) in
                    expectation.fulfill()
                })
            }
        }
    }

}

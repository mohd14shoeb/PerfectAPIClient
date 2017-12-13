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
        ("testGithubZenEndpointWithInvalidMappable", testGithubZenEndpointWithInvalidMappable),
        ("testGithubZenEndpointWithInvalidResponseMappable", testGithubZenEndpointWithInvalidResponseMappable),
        ("testGithubZenEndpointWithInvalidPaylodJSON", testGithubZenEndpointWithInvalidPaylodJSON),
        ("testGithubZenEndpointWithoutCompletion", testGithubZenEndpointWithoutCompletion),
        ("testGithubUserEndpoint", testGithubUserEndpoint),
        ("testJSONPlaceholderPostEndpoint", testJSONPlaceholderPostEndpoint),
        ("testJSONPlaceholderPostEndpointInvalidMappable", testJSONPlaceholderPostEndpointInvalidMappable),
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
    
    /// Get Post for unit test
    ///
    /// - Returns: A Post
    private func getPost() -> Post {
        return Post(title: "Mr.Robot loves PerfectAPIClient", body: "Awesome body description")
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
    
    func testGithubZenEndpointWithInvalidMappable() {
        self.performTest(#function) { (expectation) in
            GithubAPIClient.zen.request(mappable: User.self) { (result: APIClientResult<User>) in
                result.analysis(success: { (_) in
                    XCTFail("Zen request shouldn't be mappable to User")
                }, failure: { (_) in
                    expectation.fulfill()
                })
            }
        }
    }
    
    func testGithubZenEndpointWithInvalidResponseMappable() {
        self.performTest(#function) { (expectation) in
            GithubAPIClient.zen.request(completion: { (result: APIClientResult<APIClientResponse>) in
                result.analysis(success: { (response: APIClientResponse) in
                    guard response.getMappablePayload(type: User.self) == nil else {
                        XCTFail("APIResponse shouldn't be mappable to User")
                        return
                    }
                    expectation.fulfill()
                }, failure: { (error: Error) in
                    XCTFail(error.localizedDescription)
                })
            })
        }
    }
    
    func testGithubZenEndpointWithInvalidPaylodJSON() {
        self.performTest(#function) { (expectation) in
            GithubAPIClient.zen.request(completion: { (result: APIClientResult<APIClientResponse>) in
                result.analysis(success: { (response: APIClientResponse) in
                    guard response.getPayloadJSON() == nil else {
                        XCTFail("Payload shouldn't contain valid JSON")
                        return
                    }
                    expectation.fulfill()
                }, failure: { (error: Error) in
                    XCTFail(error.localizedDescription)
                })
            })
        }
    }
    
    func testGithubZenEndpointWithoutCompletion() {
        GithubAPIClient.zen.request(completion: nil)
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
    
    func testGithubUserRepositoriesEndpoint() {
        self.performTest(#function) { (expectation) in
            GithubAPIClient.repositories(userName: "sventiigi").request(mappable: Repository.self, completion: { (result: APIClientResult<[Repository]>) in
                result.analysis(success: { (repositories: [Repository]) in
                    guard let repository = repositories.first else {
                        XCTFail("Repositories Response should contain at least one element")
                        return
                    }
                    XCTAssertEqual(repository.name, "PerfectAPIClient")
                    XCTAssertEqual(repository.fullName, "SvenTiigi/PerfectAPIClient")
                    expectation.fulfill()
                }, failure: { (error: Error) in
                    XCTFail(error.localizedDescription)
                })
            })
        }
    }
    
    func testGithubUserRepositoriesEndpointWithInvalidMappable() {
        self.performTest(#function) { (expectation) in
            GithubAPIClient.repositories(userName: "sventiigi").request(mappable: User.self, completion: { (result: APIClientResult<[User]>) in
                result.analysis(success: { (users: [User]) in
                    XCTFail("Endpoint shouldn't be mappable to type User array")
                }, failure: { (error: Error) in
                    expectation.fulfill()
                })
            })
        }
    }

    // MARK: JSONPlaceholder Tests [Network]
    
    func testJSONPlaceholderPostEndpoint() {
        self.performTest(#function) { (expectation) in
            let post = self.getPost()
            JSONPlaceholderAPIClient.createPost(post).request { (result: APIClientResult<APIClientResponse>) in
                result.analysis(success: { (response: APIClientResponse) in
                    XCTAssert(response.isSuccessful)
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
    
    func testJSONPlaceholderPostEndpointInvalidMappable() {
        self.performTest(#function) { (expectation) in
            let post = self.getPost()
            JSONPlaceholderAPIClient.createPost(post).request(mappable: User.self, completion: { (result: APIClientResult<User>) in
                result.analysis(success: { (user: User) in
                    XCTFail("JSONPlaceholderAPI createPost shouldn't be mappable to user")
                }, failure: { (_) in
                    expectation.fulfill()
                })
            })
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

<p align="center"><img src="https://raw.githubusercontent.com/SvenTiigi/PerfectAPIClient/gh-pages/readMeAssets/logo.png" width="60%"></p>

<p align="center">
	<a href="https://developer.apple.com/swift/" target="_blank">
		<img src="https://img.shields.io/badge/Swift-4.0-orange.svg" alt="Swift 3.2">
	</a>
	<img src="https://img.shields.io/badge/platform-macOS%20%7C%20Linux-yellow.svg" alt="Platform">
	<a href="https://travis-ci.org/SvenTiigi/PerfectAPIClient" target="_blank">
		<img src="https://travis-ci.org/SvenTiigi/PerfectAPIClient.svg?branch=master" alt="TravisBuild">
	</a>
	<a href="https://codecov.io/gh/SvenTiigi/PerfectAPIClient" target="_blank">
		<img src="https://img.shields.io/codecov/c/github/SvenTiigi/PerfectAPIClient.svg" alt="Coverage">
	</a>
	<a href="https://codebeat.co/projects/github-com-sventiigi-perfectapiclient-master">
		<img alt="codebeat badge" src="https://codebeat.co/badges/85818a0c-1056-4f28-8348-f61ead493c81" />
	</a>
	<a href="https://sventiigi.github.io/PerfectAPIClient" target="_blank">
		<img src="https://github.com/SvenTiigi/PerfectAPIClient/blob/gh-pages/badge.svg" alt="Docs">
	</a>
	<a href="https://twitter.com/SvenTiigi" target="_blank">
		<img src="https://img.shields.io/badge/Twitter-@SvenTiigi-blue.svg" alt="@SvenTiigi">
	</a>
</p>

PerfectAPIClient is a network abstraction layer to perform network requests via [Perfect-CURL](https://github.com/PerfectlySoft/Perfect-CURL) from your [Perfect Server Side Swift](https://github.com/PerfectlySoft/Perfect) application. It's heavily inspired by [Moya](https://github.com/Moya/Moya) and it's easy and fun to use.

<p align="center"><img src="https://raw.githubusercontent.com/SvenTiigi/PerfectAPIClient/gh-pages/readMeAssets/diagram.png" width="40%"></p>

# Installation
To integrate using Apple's [Swift Package Manager](https://swift.org/package-manager/), add the following as a dependency to your `Package.swift`:

```swift
.package(url: "https://github.com/SvenTiigi/PerfectAPIClient.git", from: "1.0.0")
```
Here's an example `PackageDescription`:

```swift
// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "MyPackage",
    products: [
        .library(
            name: "MyPackage",
            targets: ["MyPackage"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/SvenTiigi/PerfectAPIClient.git", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "MyPackage",
            dependencies: ["PerfectAPIClient"]
        ),
        .testTarget(
            name: "MyPackageTests",
            dependencies: ["MyPackage", "PerfectAPIClient"]
        )
    ]
)
```

# Setup
In order to define the network abstraction layer with PerfectAPIClient, an enumeration will be declared to access the API endpoints. In this example we declare a [GithubAPIClient](https://github.com/SvenTiigi/PerfectAPIClient/blob/master/Tests/PerfectAPIClientTests/GithubAPI/GithubAPIClient.swift) to retrieve some Github [zen](https://api.github.com/zen) and [user information](https://api.github.com/users/sventiigi).

```swift
import PerfectAPIClient
import PerfectHTTP
import PerfectCURL
import ObjectMapper

/// Github API Client in order to access Github API Endpoints
enum GithubAPIClient {
    /// Retrieve zen
    case zen
    /// Retrieve user info for given username
    case user(name: String)
    /// Retrieve repositories for user name
    case repositories(userName: String)
}
```
Next up we implement the `APIClient` protocol to define the request information like base url, endpoint path, HTTP header, etc...

```swift
// MARK: APIClient

extension GithubAPIClient: APIClient {
    
    /// The base url
    var baseURL: String {
        return "https://api.github.com/"
    }
    
    /// The path for a specific endpoint
    var path: String {
        switch self {
        case .zen:
            return "zen"
        case .user(name: let name):
            return "users/\(name)"
        case .repositories(userName: let name):
            return "users/\(name)/repos"
        }
    }
    
    /// The http method
    var method: HTTPMethod {
        switch self {
        case .zen:
            return .get
        case .user:
            return .get
        case .repositories:
            return .get
        }
    }
    
    /// The HTTP headers
    var headers: [HTTPRequestHeader.Name: String]? {
        return [.userAgent: "PerfectAPIClient"]
    }
    
    /// The request payload for a POST or PUT request
    var payload: BaseMappable? {
        return nil
    }
    
    /// Advanced CURLRequest options like SSL or Proxy settings
    var options: [CURLRequest.Option]? {
        return nil
    }
    
    /// The mocked result for tests environment
    var mockedResult: APIClientResult<APIClientResponse>? {
        switch self {
        case .zen:
            let request = APIClientRequest(apiClient: self)
            let response = APIClientResponse(
	    	url: self.getRequestURL(), 
		status: .ok, 
		payload: "Some zen for you my friend", 
		request: request
            )
            return .success(response)
        default:
            return nil
        }
    }
    
}
```
There is also an [JSONPlaceholderAPIClient](https://github.com/SvenTiigi/PerfectAPIClient/blob/master/Tests/PerfectAPIClientTests/JSONPlaceholderAPI/JSONPlaceholderAPI.swift) example available.

# Usage
PerfectAPIClient enables an easy way to access an API like this:

```swift
GithubAPIClient.zen.request { (result: APIClientResult<APIClientResponse>) in
    result.analysis(success: { (response: APIClientResponse) in
        // Do awesome stuff with the response
        print(response.url) // The request url
        print(response.status) // The response HTTP status
        print(response.payload) // The response payload
        print(response.getHTTPHeader(name: .contentType)) // HTTP header field
        print(response.getPayloadJSON) // The payload as JSON/Dictionary
        print(response.getMappablePayload(type: SomethingMappable.self)) // Map payload into an object
        print(response.getMappablePayloadArray(SomethingMappable.self)) // JSON Array
    }, failure: { (error: APIClientError) in
        // Oh boy you are in trouble 😨
    }
}
```

Or even retrieve an `JSON` response as an automatically `Mappable` object.

```swift
GithubAPIClient.user(name: "sventiigi").request(mappable: User.self) { (result: APIClientResult<User>) in
    result.analysis(success: { (user: User) in
        // Do awesome stuff with the user
        print(user.name) // Sven Tiigi
    }, failure: { (error: APIClientError) in
        // Oh boy you are in trouble again 😱
    }
}
```

If your response contains an `JSON Array`:

```swift
GithubAPIClient.repositories(username: "sventiigi").request(mappable: Repository.self) { (result: APIClientResult<[Repository]>) in
    result.analysis(success: { (repositories: [Repository]) in
        // Do awesome stuff with the repositories
        print(repositories.count)
    }, failure: { (error: APIClientError) in
        // 🙈
    }
}
```

The user object in this example implements the `Mappable` protocol based on the [ObjectMapper](https://github.com/Hearst-DD/ObjectMapper) library to perform the mapping between the struct/class and `JSON`.

```swift
import ObjectMapper

struct User {
    /// The users full name
    var name: String?
    /// The user type
    var type: String?
}

// MARK: Mappable

extension User: Mappable {
    /// ObjectMapper initializer
    init?(map: Map) {}
    
    /// Mapping
    mutating func mapping(map: Map) {
        self.name   <- map["name"]
        self.type   <- map["type"]
    }
}
```

# Error Handling
When you perform the `analysis` function on the `APIClientResult` or you do a simple `switch` or `if case` on the `APIClientResult` you will retrieve an `APIClientError` via the `failure` case if an error occured. The following example shows what types of error cases are available on the `APIClientError`.

```swift
GithubAPIClient.zen.request { (result: APIClientResult<APIClientResponse>) in
    result.analysis(success: { (response: APIClientResponse) in
        // Do awesome stuff with the response
    }, failure: { (error: APIClientError) in
        // Oh boy you are in trouble 😨
	// Analysis the APIClientError
        error.analysis(mappingFailed: { (reason: String, response: APIClientResponse) in
	    // Mapping failed
        }, badResponseStatus: { (response: APIClientResponse) in
            // Bad response status
        }, connectionFailed: { (error: Error, request: APIClientRequest) in
            // Connection failure
        })
    }
}
```

* `MappingFailed`: Indicates that the Mapping between your `mappable` type and the response `JSON` doesn't match.
* `BadResponseStatus`: Indicates that the `APIClient` has received a bad response status `>= 300` or `< 200`
* `ConnectionFailed`: Indicates that an error occurred during the CURL request to the given url.

The `analysis` function on the `APIClientError` is just a convenience way to check which error type has been retrieved. Of course you can perform a `switch` or an `if case` on the `APIClientError` enumeration.

# Advanced Usage

### Modify Request URL
By overriding the `modify(requestURL ...)` function you can update the constructed request URL from baseURL and path. It's handy when you want to add a `Token` query parameter to your request url everytime instead of adding it to every path.

```swift
public func modify(requestURL: inout String) {
    requestURL += "?token=42"
}
```

### Modify JSON before Mapping
By overriding the `modify(responseJSON ...)` function you can update the response JSON before it's being mapped from JSON to your mappable type. It's handy when the response JSON is wrapped inside a `result` property.

```swift
public func modify(responseJSON: inout [String: Any], mappable: BaseMappable.Type) {
    // Try to retrieve JSON from result property
    responseJSON = responseJSON["result"] as? [String: Any] ?? responseJSON
}
```

### Modify JSON Array before Mapping
By overriding the `modify(responseJSONArray ...)` function you can update the response JSON Array before it's being mapped to an mappable array.

```swift
public func modify(responseJSONArray: inout [[String: Any]], mappable: BaseMappable.Type) {
    // Manipulate the responseJSONArray if you need so
}
```

### Should fail on bad response status
By overriding the `shouldFailOnBadResponseStatus()` function you can decide if the `APIClient` should evaluate the result as a failure if the response status code is`>= 300` or `< 200`. The default implementation returns `true` which results that an response with an bad response status code will lead to an `APIClientResult` of type `failure`.

```swift
public func shouldFailOnBadResponseStatus() -> Bool {
    // Default implementation
    return true
}
```

# Logging
By overrding the following two functions you can add logging to your request before the request started and when a response is retrieved or something else you might want to do.

### Will Perform Request
By overriding the `willPerformRequest` function you can perform logging operation or something else your might want to do, before the request of an `APIClient` will be executed.

```swift
func willPerformRequest(request: APIClientRequest) {
    print("Will perform request \(request)")
}
```

### Did Retrieve Response
By overriding the `didRetrieveResponse` function you can perform logging operation or something else your might want to do, after the response of an request for an `APIClient` is being retrieved.

```swift
func didRetrieveResponse(request: APIClientRequest, result: APIClientResult<APIClientResponse>) {
    print("Did retrieve response for request: \(request) and result: \(result)")
}
```

# Mocking

In order to define that your `APIClient` is under `Unit` or `Integration` Tests condition, you need to set the `environment` to `tests`. The recommended way is to override `setUp` and `tearDown` and update the `environment` as seen in the following example.

```swift
import XCTest
import PerfectAPIClient

class MyAPIClientTestClass: XCTestCase {

    override func setUp() {
        super.setUp()
        // Set to tests environment
        // mockedResult is used if available
        MyAPIClient.environment = .tests
    }
    
    override func tearDown() {
        super.tearDown()
        // Reset to default environment
        MyAPIClient.environment = .default
    }

    func testMyAPIClient() {
    	// Your test logic
    }

}
```

### MockedResult

In order to add mocking to your APIClient for unit testing your application you can return an `APIClientResult` via the `mockedResult` protocol variable. The `mockedResult` is only used when you return an `APIClientResult` and the current `environment` is set to `tests`.

```swift
var mockedResult: APIClientResult<APIClientResponse>? {
    switch self {
    case .zen:
        // This result will be used when unit tests are running
        let request = APIClientRequest(apiClient: self)
        let response = APIClientResponse(
		url: self.getRequestURL(), 
		status: .ok, 
		payload: "Keep it logically awesome.", 
		request: request
	)
        return .success(response)
    case .user:
        // A real network request will be performed when unit tests are running
        return nil
    }
}
```
For more details checkout the [PerfectAPIClientTests.swift](https://github.com/SvenTiigi/PerfectAPIClient/blob/master/Tests/PerfectAPIClientTests/PerfectAPIClientTests.swift) file.

# Slashes
When your ask yourself where to put the slash `/` when returning a String for `baseURL` and `path` 🤔

This is the recommended way ☝️:

```swift
/// The base url
var baseURL: String {
    return "https://api.awesome.com/"
}
    
/// The path for a specific endpoint
var path: String {
    return "users"
}
```
Put a slash at the end of your `baseURL` and skip the slash at the beginning of your `path`. But don't worry `APIClient` has a default implementation for the `getRequestURL()` function which add a slash to the `baseURL` if you forgot it and remove the first character of your `path` if it's a slash. If you want to change the behavior just override the function 👌

# RawRepresentable
As most of your enumeration cases will be mixed with [Associated Values](https://developer.apple.com/library/content/documentation/Swift/Conceptual/Swift_Programming_Language/Enumerations.html#//apple_ref/doc/uid/TP40014097-CH12-ID148) and some without, it's hard to retrieve the enumerations name as a String because you can't declare an Enumeration with associated values like this: 

``` swift
// ❌ Error: enum with raw type cannot have cases with arguments
enum GithubAPIClient: String {
    case zen
    case user(name: String)
}
```

So here is an example to retrieve the enumeration name via the `rawValue` property from the `RawRepresentable` protocol:

```swift
enum GithubAPIClient {
    // Without associated value
    case zen
    // With associated value
    case user(name: String)
}

extension GithubAPIClient: RawRepresentable {
    
    /// Associated type RawValue as String
    typealias RawValue = String
    
    /// RawRepresentable initializer. Which always returns nil
    ///
    /// - Parameters:
    ///   - rawValue: The rawValue
    init?(rawValue: String) {
        // Returning nil to avoid constructing enum with String
        return nil
    }
    
    /// The enumeration name as String
    var rawValue: RawValue {
        // Retrieve label via Mirror for Enum with associcated value
        guard let label = Mirror(reflecting: self).children.first?.label else {
            // Return String describing self enumeration with no asscoiated value
            return String(describing: self)
        }
        // Return label
        return label
    }
    
}
```
Full example [GithubAPIClient.swift](https://github.com/SvenTiigi/PerfectAPIClient/blob/master/Tests/PerfectAPIClientTests/GithubAPI/GithubAPIClient.swift)

### Usage

```swift
print(GithubAPIClient.zen.rawValue) // zen
print(GithubAPIClient.user(name: "sventiigi").rawValue) // user
```

Awesome 😎

# Linux Build Notes
Ensure that you have installed `libcurl`.

```
sudo apt-get install libcurl4-openssl-dev
```
If you run into problems with `JSON-Mapping` on `Int` and `Double` values using the [ObjectMapper](https://github.com/Hearst-DD/ObjectMapper) library under Linux, please see this [issue](https://github.com/Hearst-DD/ObjectMapper/issues/884).

# Dependencies
PerfectAPIClient is using the following dependencies:

* [Perfect-HTTP](https://github.com/PerfectlySoft/Perfect-HTTP)
* [Perfect-CURL](https://github.com/PerfectlySoft/Perfect-CURL)
* [ObjectMapper](https://github.com/Hearst-DD/ObjectMapper)

# Contributing
Contributions are very welcome 🙌 🤓

# To-Do

- [ ] Improve Unit-Tests
- [ ] Improve Linux compatibility
- [ ] Add automated Jazzy documentation generation via Travis CI

# License

```
MIT License

Copyright (c) 2017 Sven Tiigi

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

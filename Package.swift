// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "PerfectAPIClient",
    products: [
        .library(
            name: "PerfectAPIClient",
            targets: [
                "PerfectAPIClient"
            ]),
    ],
    dependencies: [
        .package(url: "https://github.com/PerfectlySoft/Perfect-HTTP.git", from: "3.0.0"),
        .package(url: "https://github.com/PerfectlySoft/Perfect-CURL.git", from: "3.0.0"),
        .package(url: "https://github.com/Hearst-DD/ObjectMapper.git", from: "3.0.0"),
        .package(url: "https://github.com/eman6576/SwiftEnv.git", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "PerfectAPIClient",
            dependencies: [
                "PerfectHTTP",
                "PerfectCURL",
                "ObjectMapper",
                "SwiftEnv"
            ]),
        .testTarget(
            name: "PerfectAPIClientTests",
            dependencies: [
                "PerfectAPIClient"
            ]),
    ]
)

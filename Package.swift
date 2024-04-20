// swift-tools-version:5.9

import PackageDescription

let webAuthPlatforms: [Platform] = [.iOS, .macOS, .macCatalyst, .visionOS]
let swiftSettings: [SwiftSetting] = [.define("WEB_AUTH_PLATFORM", .when(platforms: webAuthPlatforms))]

let package = Package(
    name: "Auth0",
    platforms: [.iOS(.v13), .macOS(.v11), .tvOS(.v13), .watchOS(.v7), .visionOS(.v1)],
    products: [.library(name: "Auth0", targets: ["Auth0"])],
    dependencies: [
        .package(url: "https://github.com/auth0/JWTDecode.swift.git", .upToNextMajor(from: "3.1.0")),
        .package(url: "https://github.com/ryanbennettvoid/SimpleKeychain", .upToNextMajor(from: "1.1.1")),
    ],
    targets: [
        .target(
            name: "Auth0",
            dependencies: [
                .product(name: "JWTDecode", package: "JWTDecode.swift"),
                .product(name: "SimpleKeychain", package: "SimpleKeychain")
            ],
            path: "Auth0",
            exclude: ["Info.plist"],
            swiftSettings: swiftSettings),
    ]
)

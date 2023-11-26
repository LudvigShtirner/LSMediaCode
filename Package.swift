// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

private let mediaCode = "LSMediaCode"
private let mediaCodeTests = "LSMediaCodeTests"

let package = Package(
    name: mediaCode,
    platforms: [.iOS(.v13)],
    products: [
        .library(name: mediaCode,
                 targets: [mediaCode])
    ],
    dependencies: [
        
    ],
    targets: [
        .target(
            name: mediaCode,
            dependencies: []),
        .testTarget(
            name: mediaCodeTests,
            dependencies: [
                .byName(name: mediaCode)
            ]),
    ]
)

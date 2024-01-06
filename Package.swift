// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

struct RemotePackage {
    let name: String
    let productName: String
    let url: String
    
    init(name: String,
         productName: String? = nil,
         url: String) {
        self.name = name
        self.productName = productName ?? name
        self.url = url
    }
}

private let mediaCode = "LSMediaCode"
private let mediaCodeTests = "LSMediaCodeTests"

private let supportCode = RemotePackage(name: "SupportCode",
                                        url: "https://github.com/LudvigShtirner/SupportCode.git")

let package = Package(
    name: mediaCode,
    platforms: [.iOS(.v15)],
    products: [
        .library(name: mediaCode,
                 targets: [mediaCode])
    ],
    dependencies: [
        .package(url: supportCode.url, branch: "main")
    ],
    targets: [
        .target(
            name: mediaCode,
            dependencies: [
                .byName(name: supportCode.name)
            ]),
        .testTarget(
            name: mediaCodeTests,
            dependencies: [
                .byName(name: mediaCode)
            ]),
    ]
)

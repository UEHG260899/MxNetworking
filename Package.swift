// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "MxNetworking",
    platforms: [.iOS(.v13)],
    products: [
        .library(
            name: "MxNetworking",
            targets: ["MxNetworking"]
        )
    ],
    targets: [
        .target(
            name: "MxNetworkingDemo",
            dependencies: ["MxNetworking"],
            path: "MxNetworking/MxNetworkingDemo",
            resources: [.process("Images.xcassets")]
        ),
        .target(
            name: "MxNetworking",
            path: "MxNetworking/MxNetworking"
        ),
        .testTarget(
            name: "MxNetworkingTests",
            dependencies: ["MxNetworking"],
            path: "MxNetworking/MxNetworkingTests"
        )
    ],
    swiftLanguageVersions: [.v5]
)

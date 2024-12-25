// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftSearch",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "SwiftSearchCore",
            targets: ["SwiftSearchCore"]
        ),
        .executable(
            name: "SwiftSearch",
            targets: ["SwiftSearch"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/stephencelis/SQLite.swift.git", from: "0.14.1")
    ],
    targets: [
        .target(
            name: "SwiftSearchCore",
            dependencies: [
                .product(name: "SQLite", package: "SQLite.swift")
            ]
        ),
        .executableTarget(
            name: "SwiftSearch",
            dependencies: ["SwiftSearchCore"]
        ),
        .testTarget(
            name: "SwiftSearchTests",
            dependencies: ["SwiftSearch", "SwiftSearchCore"]
        )
    ]
)

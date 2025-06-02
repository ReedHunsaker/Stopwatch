// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Stopwatch",
    platforms: [
        .iOS(.v18)
    ],
    products: [
        .library(
            name: "Stopwatch",
            targets: ["Stopwatch"]
        ),
    ],
    targets: [
        .target(
            name: "Stopwatch",
            path: "Sources"
        ),
        .testTarget(
            name: "StopwatchTests",
            dependencies: ["Stopwatch"],
            path: "Tests"
        ),
    ]
)

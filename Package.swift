// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "AsyncReactorKit",
    products: [
        .library(
            name: "AsyncReactorKit",
            targets: ["AsyncReactorKit"]),
    ],
    targets: [
        .target(
            name: "AsyncReactorKit"
		)
    ]
)

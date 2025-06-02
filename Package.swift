// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "AsyncReactorKit",
	platforms: [
		.iOS(.v13),
		.macOS(.v10_15)
	],
    products: [
        .library(
            name: "AsyncReactorKit",
            targets: ["AsyncReactorKit"]),
    ],
	dependencies: [
		   .package(url: "https://github.com/ReactorKit/WeakMapTable.git", from: "1.2.1")
	   ],
    targets: [
        .target(
            name: "AsyncReactorKit",
			dependencies: [
				"WeakMapTable"
			]
		),
    ]
)

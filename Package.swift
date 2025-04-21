// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "InteractiveTextView",
	platforms: [.macOS(.v14)],
	products: [
		.library(
			name: "InteractiveTextView",
			targets: ["InteractiveTextView"]
		),
	],
	targets: [
		.target(
			name: "InteractiveTextView",
			dependencies: []
		)
	]
)

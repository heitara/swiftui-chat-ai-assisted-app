// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-gemini-api",
	platforms: [
		.iOS(.v17),
		.macOS(.v15)
	],
    products: [
        .library(
            name: "SwiftGeminiApi",
            targets: ["SwiftGeminiApi"]
        ),
    ],
    targets: [
        .target(
            name: "SwiftGeminiApi",
			linkerSettings: [
				.linkedFramework("AudioToolbox"),
				.linkedFramework("AVFoundation"),
				.linkedFramework("AVFAudio"),
			]
        ),

    ]
)

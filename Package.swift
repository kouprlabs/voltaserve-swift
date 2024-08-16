// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "Voltaserve",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15)
    ],
    products: [
        .library(
            name: "Voltaserve",
            targets: ["Voltaserve"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.9.1")),
        .package(url: "https://github.com/SimplyDanny/SwiftLintPlugins", .upToNextMajor(from: "0.56.1")),
        .package(url: "https://github.com/nicklockwood/SwiftFormat", from: "0.54.0")
    ],
    targets: [
        .target(
            name: "Voltaserve",
            dependencies: ["Alamofire"],
            path: "Sources",
            plugins: [.plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLintPlugins")]
        ),
        .testTarget(
            name: "VoltaserveTests",
            dependencies: ["Voltaserve"],
            path: "Tests",
            plugins: [.plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLintPlugins")]
        )
    ]
)

// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "Voltaserve",
    platforms: [
        .iOS(.v13),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "Voltaserve",
            targets: ["Voltaserve"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.9.1"))
    ],
    targets: [
        .target(
            name: "Voltaserve",
            dependencies: ["Alamofire"],
            path: "Sources"
        ),
        .testTarget(
            name: "VoltaserveTests",
            dependencies: ["Voltaserve"],
            path: "Tests",
            resources: [.process("Resources")]
        )
    ]
)

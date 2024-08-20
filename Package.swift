// swift-tools-version: 5.10

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
    targets: [
        .target(
            name: "Voltaserve",
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

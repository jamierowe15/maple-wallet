// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Transfers",
    platforms: [.iOS(.v18), .macOS(.v15)],
    products: [.library(name: "Transfers", targets: ["Transfers"])],
    dependencies: [
        .package(path: "../Core"),
        .package(path: "../DesignSystem"),
        .package(path: "../Networking"),
    ],
    targets: [
        .target(name: "Transfers", dependencies: ["Core", "DesignSystem", "Networking"]),
        .testTarget(name: "TransfersTests", dependencies: ["Transfers", "Core"]),
    ]
)

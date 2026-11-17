// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Accounts",
    platforms: [.iOS(.v18), .macOS(.v15)],
    products: [.library(name: "Accounts", targets: ["Accounts"])],
    dependencies: [
        .package(path: "../Core"),
        .package(path: "../DesignSystem"),
        .package(path: "../Networking"),
    ],
    targets: [
        .target(
            name: "Accounts",
            dependencies: ["Core", "DesignSystem", "Networking"],
            resources: [.process("Fixtures")]
        ),
        .testTarget(name: "AccountsTests", dependencies: ["Accounts", "Core", "Networking"]),
    ]
)

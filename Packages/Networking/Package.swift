// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Networking",
    platforms: [.iOS(.v18), .macOS(.v15)],
    products: [.library(name: "Networking", targets: ["Networking"])],
    dependencies: [.package(path: "../Core")],
    targets: [
        .target(name: "Networking", dependencies: ["Core"]),
        .testTarget(name: "NetworkingTests", dependencies: ["Networking", "Core"]),
    ]
)

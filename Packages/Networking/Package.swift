// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Networking",
    platforms: [.iOS(.v18), .macOS(.v15)],
    products: [.library(name: "Networking", targets: ["Networking"])],
    dependencies: [
        .package(path: "../Core"),
        // CryptoKit is Apple-only; swift-crypto has the same API on Windows/Linux.
        .package(url: "https://github.com/apple/swift-crypto.git", from: "3.0.0"),
    ],
    targets: [
        .target(name: "Networking", dependencies: [
            "Core",
            .product(name: "Crypto", package: "swift-crypto", condition: .when(platforms: [.windows, .linux])),
        ]),
        .testTarget(name: "NetworkingTests", dependencies: ["Networking", "Core"]),
    ]
)

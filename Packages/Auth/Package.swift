// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Auth",
    platforms: [.iOS(.v18), .macOS(.v15)],
    products: [.library(name: "Auth", targets: ["Auth"])],
    dependencies: [
        .package(path: "../Core"),
        .package(path: "../Networking"),
        .package(url: "https://github.com/apple/swift-crypto.git", from: "3.0.0"),
    ],
    targets: [
        .target(name: "Auth", dependencies: [
            "Core",
            "Networking",
            .product(name: "Crypto", package: "swift-crypto", condition: .when(platforms: [.windows, .linux])),
        ]),
        .testTarget(name: "AuthTests", dependencies: ["Auth", "Core", "Networking"]),
    ]
)

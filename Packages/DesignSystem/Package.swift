// swift-tools-version: 6.0
import PackageDescription

// UI-only package. Everything is wrapped in `#if canImport(UIKit)`, so on
// Windows/macOS command-line builds it compiles to an empty module.
let package = Package(
    name: "DesignSystem",
    platforms: [.iOS(.v18), .macOS(.v15)],
    products: [.library(name: "DesignSystem", targets: ["DesignSystem"])],
    targets: [.target(name: "DesignSystem")]
)

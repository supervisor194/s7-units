// swift-tools-version: 6.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "S7Units",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "S7Units",
            targets: ["S7Units"]
        ),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "S7Units"
        ),
        .testTarget(
            name: "S7UnitsTests",
            dependencies: ["S7Units"]
        ),
    ],
    swiftLanguageModes: [.v6]
)

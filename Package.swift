// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Tray",
    platforms: [
        .iOS(.v18), .macOS(.v14)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Tray",
            targets: ["Tray"]),
    ],
    dependencies: [
        .package(url: "https://github.com/SwiftUIX/SwiftUIX", branch: "master")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Tray",
            dependencies: ["SwiftUIX"]
        ),
        .testTarget(
            name: "TrayTests",
            dependencies: ["Tray"]
        ),
    ]
)

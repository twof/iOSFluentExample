// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "iOSFluentPackage",
    platforms: [.iOS(.v13)],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "iOSFluentPackage",
            targets: ["iOSFluentPackage"]),
    ],
    dependencies: [
      .package(url: "https://github.com/vapor/fluent-sqlite-driver.git", from: "4.0.0-alpha.3"),
      .package(url: "https://github.com/vapor/fluent-kit", from: "1.0.0-alpha.3.1"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "iOSFluentPackage",
            dependencies: ["FluentSQLiteDriver", "FluentKit"]),
        .testTarget(
            name: "iOSFluentPackageTests",
            dependencies: ["iOSFluentPackage"]),
    ]
)

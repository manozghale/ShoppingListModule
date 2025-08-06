// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ShoppingListModule",
    platforms: [
        .iOS(.v17) // Required for SwiftData
    ],
    products: [
        .library(
            name: "ShoppingListModule",
            targets: ["ShoppingListModule"]
        ),
    ],
    dependencies: [
        // No external dependencies to keep it lightweight
    ],
    targets: [
        .target(
            name: "ShoppingListModule",
            dependencies: []
        ),
        .testTarget(
            name: "ShoppingListModuleTests",
            dependencies: ["ShoppingListModule"]
        ),
    ]
)

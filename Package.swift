// swift-tools-version: 6.1
import PackageDescription

let package = Package(
    name: "TestSPMIntegration",
    platforms: [.iOS(.v17)],
    dependencies: [
        .package(path: "../ShoppingListModule")
    ],
    targets: [
        .executableTarget(
            name: "TestSPMIntegration",
            dependencies: ["ShoppingListModule"]
        )
    ]
)

// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "CapacitorNativePermissions",
    platforms: [.iOS(.v14)],
    products: [
        .library(
            name: "CapacitorNativePermissions",
            targets: ["NativePermissionsPlugin"])
    ],
    dependencies: [
        .package(url: "https://github.com/ionic-team/capacitor-swift-pm.git", from: "7.0.0")
    ],
    targets: [
        .target(
            name: "NativePermissionsPlugin",
            dependencies: [
                .product(name: "Capacitor", package: "capacitor-swift-pm"),
                .product(name: "Cordova", package: "capacitor-swift-pm")
            ],
            path: "ios/Sources/NativePermissionsPlugin"),
        .testTarget(
            name: "NativePermissionsPluginTests",
            dependencies: ["NativePermissionsPlugin"],
            path: "ios/Tests/NativePermissionsPluginTests")
    ]
)

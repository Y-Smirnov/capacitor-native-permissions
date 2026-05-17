// swift-tools-version: 6.1
import PackageDescription

let package = Package(
    name: "CapacitorNativePermissions",
    platforms: [.iOS(.v14)],
    products: [
        .library(
            name: "CapacitorNativePermissions",
            targets: ["NativePermissionsPlugin"])
    ],
    traits: [
        .default(enabledTraits: []),

        .trait(
            name: "PERMISSION_NOTIFICATIONS",
            description: "Notifications permission support."
        ),
        .trait(
            name: "PERMISSION_APP_TRACKING_TRANSPARENCY",
            description: "App Tracking Transparency permission support."
        ),
        .trait(
            name: "PERMISSION_BLUETOOTH",
            description: "Bluetooth permission support."
        ),
        .trait(
            name: "PERMISSION_CALENDAR",
            description: "Calendar permission support."
        ),
        .trait(
            name: "PERMISSION_REMINDERS",
            description: "Reminders permission support."
        ),
        .trait(
            name: "PERMISSION_CAMERA",
            description: "Camera permission support."
        ),
        .trait(
            name: "PERMISSION_CONTACTS",
            description: "Contacts permission support."
        ),
        .trait(
            name: "PERMISSION_MEDIA",
            description: "Media Library support."
        ),
        .trait(
            name: "PERMISSION_RECORD",
            description: "Record permission support."
        ),
        .trait(
            name: "PERMISSION_LOCATION_FOREGROUND",
            description: "Foreground location permission support."
        ),
        .trait(
            name: "PERMISSION_LOCATION_BACKGROUND",
            description: "Background location permission support."
        )
    ],
    dependencies: [
        .package(url: "https://github.com/ionic-team/capacitor-swift-pm.git", "7.0.0"..<"9.0.0")
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

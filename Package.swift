// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "OpenPrintTagKit",
    platforms: [
        .iOS(.v17),
    ],
    products: [
        .library(name: "OpenPrintTagKit", targets: ["OpenPrintTagKit"]),
    ],
    targets: [
        .target(name: "OpenPrintTagKit"),
        .testTarget(
            name: "OpenPrintTagKitTests",
            dependencies: ["OpenPrintTagKit"]
        ),
    ]
)

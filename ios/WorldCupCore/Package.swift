// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "WorldCupCore",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "WorldCupCore", targets: ["WorldCupCore"]),
    ],
    targets: [
        .target(
            name: "WorldCupCore",
            resources: [.process("Resources")]
        ),
        .testTarget(
            name: "WorldCupCoreTests",
            dependencies: ["WorldCupCore"],
            resources: [.process("Resources")]
        ),
    ]
)

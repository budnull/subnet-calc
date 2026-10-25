// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SubnetCalc",
    defaultLocalization: "en",
    platforms: [.macOS(.v13)],
    products: [
        .library(name: "NetworkCalcKit", targets: ["NetworkCalcKit"]),
    ],
    targets: [
        .target(
            name: "NetworkCalcKit",
            path: "Sources/NetworkCalcKit"
        ),
        .executableTarget(
            name: "SubnetCalc",
            dependencies: ["NetworkCalcKit"],
            path: "Sources/SubnetCalc",
            resources: [.process("Resources")]
        ),
        .testTarget(
            name: "NetworkCalcKitTests",
            dependencies: ["NetworkCalcKit"],
            path: "Tests/NetworkCalcKitTests"
        ),
    ]
)

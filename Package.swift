// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "FitnessApp",
    platforms: [.iOS(.v16)],
    products: [
        .executable(name: "FitnessApp", targets: ["FitnessApp"])
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "FitnessApp",
            path: "Sources/FitnessApp",
            resources: [.process("Resources")],
            linkerSettings: [
                .linkedFramework("HealthKit"),
                .linkedFramework("CloudKit")
            ]
        )
    ]
)

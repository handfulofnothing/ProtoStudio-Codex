// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "FramerClassic",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "FramerClassic",
            targets: ["FramerClassic"]
        )
    ],
    dependencies: [
    ],
    targets: [
        .executableTarget(
            name: "FramerClassic",
            dependencies: [],
            path: ".",
            exclude: [
                "README.md",
                "instructions.md",
                "scripts"
            ],
            resources: [
                .copy("Resources")
            ]
        )
    ]
)

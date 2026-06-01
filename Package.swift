// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "PomodoroTimer",
    platforms: [.macOS(.v14)],
    products: [
        .executable(name: "PomodoroTimer", targets: ["PomodoroTimer"]),
    ],
    targets: [
        .executableTarget(
            name: "PomodoroTimer",
            path: "Sources/PomodoroTimer"
        ),
    ]
)

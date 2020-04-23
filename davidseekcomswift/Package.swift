// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "Davidseekcomswift",
    products: [
        .executable(name: "Davidseekcomswift", targets: ["Davidseekcomswift"])
    ],
    dependencies: [
        .package(url: "https://github.com/johnsundell/publish.git", from: "0.3.0")
    ],
    targets: [
        .target(
            name: "Davidseekcomswift",
            dependencies: ["Publish"]
        )
    ]
)
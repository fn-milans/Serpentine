// swift-tools-version:6.1
// SPDX-License-Identifier: GPL-2.0-or-later
// Part of Serpentine, a control app for Razer mice on macOS. See LICENSE and NOTICE.md.
import PackageDescription

let package = Package(
    name: "Serpentine",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "Serpentine", targets: ["Serpentine"]),
        .executable(name: "serpentine-cli", targets: ["SerpentineCLI"]),
    ],
    targets: [
        // Razer's HID protocol: report framing, command builders and parsers, the Bluetooth
        // translation, onboard tables, the device registry. Pure; no AppKit, no IOKit.
        .target(
            name: "RazerProtocol",
            path: "Sources/RazerProtocol"
        ),
        // Talking to the hardware: USB HID and Bluetooth LE transports, device discovery and
        // monitoring, and the probes the CLI runs.
        .target(
            name: "RazerDeviceKit",
            dependencies: ["RazerProtocol"],
            path: "Sources/RazerDeviceKit"
        ),
        .executableTarget(
            name: "Serpentine",
            dependencies: ["RazerProtocol", "RazerDeviceKit"],
            path: "Sources/Serpentine",
            // macOS draws an app in the style of the SDK its binary says it was built with:
            // 26 or later gets the glass toolbar and shrink-wrapped segmented controls. The
            // window was designed in the macOS 14 style, so the binary says 14 whichever Xcode
            // builds it, and `swift run`, `render-window` and a release all look the same.
            // (Decision D21.)
            linkerSettings: [
                .unsafeFlags(["-Xlinker", "-platform_version", "-Xlinker", "macos",
                              "-Xlinker", "14.0", "-Xlinker", "14.0"]),
            ]
        ),
        // Hardware diagnostics, without AppKit: `swift run serpentine-cli battery`.
        .executableTarget(
            name: "SerpentineCLI",
            dependencies: ["RazerProtocol", "RazerDeviceKit"],
            path: "Sources/SerpentineCLI"
        ),
        // Tests import the executable target directly (@testable) — supported by SwiftPM on
        // macOS, and avoids splitting a library target just to gain testability.
        .testTarget(
            name: "RazerProtocolTests",
            dependencies: ["RazerProtocol"],
            path: "Tests/RazerProtocolTests"
        ),
        .testTarget(
            name: "RazerDeviceKitTests",
            dependencies: ["RazerDeviceKit", "RazerProtocol"],
            path: "Tests/RazerDeviceKitTests"
        ),
        .testTarget(
            name: "SerpentineTests",
            dependencies: ["Serpentine", "RazerProtocol", "RazerDeviceKit"],
            path: "Tests/SerpentineTests"
        ),
    ]
)

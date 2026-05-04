// swift-tools-version:6.0
// MonstaGuru - macOS App for Audiothingies MicroMonsta 2
// Created by Mistral Vibe Code (Project Architect Agent)

import PackageDescription

let package = Package(
    name: "MonstaGuru",
    platforms: [
        .macOS("14.0") // Sonoma+ for SwiftData and modern SwiftUI
    ],
    products: [
        .executable(
            name: "MonstaGuru",
            targets: ["MonstaGuru"]
        )
    ],
    dependencies: [
        // Native Apple frameworks (no third-party dependencies)
        // For SwiftUI testing (if needed later):
        // .package(url: "https://github.com/nalexn/ViewInspector.git", from: "0.9.0")
    ],
    targets: [
        // Main App Target
        .target(
            name: "MonstaGuru",
            dependencies: [
                "App",
                "Data",
                "MIDI",
                "UI"
            ],
            resources: [
                .process("Resources")
            ],
            swiftSettings: [
                // Enable strict concurrency checking
                .enableExperimentalFeature("StrictConcurrency"),
                // Enable modern Swift features
                .enableUpcomingFeature("ExistentialAny")
            ]
        ),
        
        // App Module (Entry Point, App Delegate, Main Scene)
        .target(
            name: "App",
            dependencies: [
                "Data",
                "MIDI",
                "UI"
            ],
            path: "Sources/App",
            exclude: ["Info.plist"],
            resources: [
                .process("Info.plist")
            ]
        ),
        
        // Data Module (SwiftData Models, Repositories)
        .target(
            name: "Data",
            dependencies: [],
            path: "Sources/Data",
            exclude: []
        ),
        
        // MIDI Module (CoreMIDI Integration)
        .target(
            name: "MIDI",
            dependencies: [
                "Data"
            ],
            path: "Sources/MIDI",
            exclude: []
        ),
        
        // UI Module (SwiftUI Views, ViewModels)
        .target(
            name: "UI",
            dependencies: [
                "Data",
                "MIDI"
            ],
            path: "Sources/UI",
            exclude: []
        ),
        
        // Unit Tests
        .testTarget(
            name: "MonstaGuruUnitTests",
            dependencies: [
                "App",
                "Data",
                "MIDI",
                "UI"
            ],
            path: "Tests/UnitTests",
            exclude: []
        ),
        
        // UI Tests
        .testTarget(
            name: "MonstaGuruUITests",
            dependencies: [
                "MonstaGuru"
            ],
            path: "Tests/UITests",
            exclude: []
        )
    ],
    swiftLanguageModes: [.v5]
)

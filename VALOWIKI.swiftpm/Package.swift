// swift-tools-version: 6.0

// VALOWIKI — Swift Playgrounds app package.
// Open VALOWIKI.swiftpm in Swift Playgrounds (iPadOS 17+) or in Xcode 16+.

import PackageDescription

let package = Package(
    name: "VALOWIKI",
    platforms: [
        .iOS("17.0")
    ],
    products: [
        .iOSApplication(
            name: "VALOWIKI",
            targets: ["AppModule"],
            bundleIdentifier: "com.valowiki.app",
            teamIdentifier: "",
            displayVersion: "1.0",
            bundleVersion: "1",
            appIcon: .placeholder(icon: .magic),
            accentColor: .init(color: .init(hex: 0xFF4655)),
            supportedDeviceFamilies: [
                .pad,
                .phone
            ],
            supportedInterfaceOrientations: [
                .portrait,
                .landscapeRight,
                .landscapeLeft,
                .portraitUpsideDown(.when(deviceFamilies: [.pad]))
            ]
        )
    ],
    targets: [
        .executableTarget(
            name: "AppModule",
            path: "."
        )
    ]
)

// swift-tools-version: 5.9

// VALOWIKI — Swift Playgrounds app package.
// Open VALOWIKI.swiftpm in Swift Playgrounds (iPadOS 17+) or in Xcode 15+.

import PackageDescription

let package = Package(
    name: "VALOWIKI",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .iOSApplication(
            name: "VALOWIKI",
            targets: ["AppModule"],
            bundleIdentifier: "com.valowiki.app",
            teamIdentifier: "",
            displayVersion: "1.0",
            bundleVersion: "1",
            appIcon: .placeholder(icon: .bolt),
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

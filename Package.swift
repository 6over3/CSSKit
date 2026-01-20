// swift-tools-version: 6.0

import CompilerPluginSupport
import PackageDescription

let package = Package(
    name: "CSSKit",
    platforms: [
        .macOS(.v13),
        .iOS(.v16),
        .tvOS(.v16),
        .watchOS(.v9),
    ],
    products: [
        .library(
            name: "CSSKit",
            targets: ["CSSKit"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-syntax.git", from: "602.0.0"),
        .package(url: "https://github.com/scinfu/SwiftSoup.git", from: "2.11.2"),
        .package(url: "https://github.com/swiftlang/swift-docc-plugin", from: "1.4.5"),
    ],
    targets: [
        .target(
            name: "CSSKit",
            dependencies: ["CSSKitMacros"]
        ),
        .target(
            name: "CSSKitMacros",
            dependencies: ["CSSKitMacrosPlugin"]
        ),
        .macro(
            name: "CSSKitMacrosPlugin",
            dependencies: [
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
            ]
        ),

        .executableTarget(
            name: "CSSKitExample",
            dependencies: [
                "CSSKit",
                .product(name: "SwiftSoup", package: "SwiftSoup"),
            ],
            path: "Examples/CSSKitExample"
        ),

        .testTarget(
            name: "CSSKitTests",
            dependencies: ["CSSKit"],
            resources: [
                .copy("Resources/css-parsing-tests"),
            ]
        ),
        .testTarget(
            name: "CSSKitMacrosTests",
            dependencies: [
                "CSSKitMacros",
                "CSSKitMacrosPlugin",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
            ]
        ),
    ]
)

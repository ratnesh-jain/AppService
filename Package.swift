// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

extension Target.Dependency {
    static var moya: Target.Dependency {
        .product(name: "Moya", package: "Moya")
    }
    
    static var tca: Target.Dependency {
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
    }
    
    static var swiftMacroTesting: Self {
        .product(name: "MacroTesting", package: "swift-macro-testing")
    }
}

let package = Package(
    name: "AppService",
    platforms: [.macOS(.v10_15), .iOS(.v13), .tvOS(.v13), .watchOS(.v6), .macCatalyst(.v13)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "AppService",
            targets: ["AppService"]
        ),
        .executable(
            name: "AppServiceClient",
            targets: ["AppServiceClient"]
        ),
    ],
    dependencies: [
        // Depend on the Swift 5.9 release of SwiftSyntax
        .package(url: "https://github.com/apple/swift-syntax.git", from: "509.0.0"),
        .package(url: "https://github.com/pointfreeco/swift-macro-testing", .upToNextMajor(from: "0.2.1")),
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", .upToNextMajor(from: "1.0.0")),
        .package(url: "https://github.com/Moya/Moya.git", .upToNextMajor(from: "15.0.0")),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        // Macro implementation that performs the source transformation of a macro.
        .macro(
            name: "AppServiceMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
                "AppServiceSupport"
            ]
        ),

        // Library that exposes a macro as part of its API, which is used in client programs.
        .target(name: "AppServiceSupport", dependencies: [.moya]),
        .target(name: "AppService", dependencies: ["AppServiceMacros", .moya, .tca, "AppServiceSupport"]),

        // A client of the library, which is able to use the macro in its own code.
        .executableTarget(name: "AppServiceClient", dependencies: ["AppService"]),

        // A test target used to develop the macro implementation.
        .testTarget(
            name: "AppServiceTests",
            dependencies: [
                "AppServiceMacros",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
                .swiftMacroTesting,
            ]
        ),
    ]
)

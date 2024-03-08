// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-graphql-code-gen",
    platforms: [
        .macOS(.v10_15),
    ],
    products: [
        // Products can be used to vend plugins, making them visible to other packages.
        .plugin(
            name: "SwiftGraphQLCodeGenCLIPlugin",
            targets: ["CLI"]
        ),
        .executable(
            name: "SwiftGraphQLCodeGenCLIExecutable",
            targets: ["SwiftGraphQLCodeGenCLIExecutable"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.0.0"),
        .package(url: "https://github.com/JohnSundell/Files", from: "4.0.0"),
        .package(url: "https://github.com/apple/swift-format", "508.0.0" ..< "510.0.0"),
        .package(url: "https://github.com/jpsim/Yams.git", from: "5.0.0"),
        .package(url: "https://github.com/dominicegginton/Spinner", from: "2.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(name: "GraphQLAST", dependencies: [], path: "Sources/GraphQLAST"),
        .target(
            name: "SwiftGraphQLCodegen",
            dependencies: [
                "GraphQLAST",
                .product(name: "SwiftFormat", package: "swift-format"),
                .product(name: "SwiftFormatConfiguration", package: "swift-format"),
            ]
        ),

        .testTarget(
            name: "GraphQLASTTests",
            dependencies: [
                "GraphQLAST",
            ]
        ),
        .testTarget(
            name: "SwiftGraphQLCodegenTests",
            dependencies: [
                "GraphQLAST",
                "SwiftGraphQLCodegen",
            ]
        ),

        // Executables

        .executableTarget(
            name: "SwiftGraphQLCodeGenCLIExecutable",
            dependencies: [
                .product(name: "Files", package: "Files"),
                .product(name: "Spinner", package: "Spinner"),
                .product(name: "Yams", package: "Yams"),
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                "SwiftGraphQLCodegen",
            ],
            path: "Plugins/SwiftGraphQLCLI/Executable"
        ),
        .plugin(
            name: "CLI",
            capability: .command(intent: .custom(
                verb: "swift-graphql",
                description: "prints hello world"
            )),
            dependencies: [
                "SwiftGraphQLCodeGenCLIExecutable",
            ],
            path: "Plugins/SwiftGraphQLCLI/Plugin"
        ),
    ]
)

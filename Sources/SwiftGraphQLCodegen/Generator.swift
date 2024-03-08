import Foundation
import GraphQLAST
import Files

/// Structure that holds methods for SwiftGraphQL query-builder generation.
public struct GraphQLCodegen {

    /// Map of supported scalars.
    private let scalars: ScalarMap

    // MARK: - Initializer

    public init(scalars: ScalarMap) {
        self.scalars = scalars
    }

    // MARK: - Methods

    public struct FileData {
        public let filename: String
        public let contents: String
    }

    /// Generates a SwiftGraphQL Selection File (i.e. the code that tells how to define selections).
    public func generate(schema: Schema) throws -> [FileData] {
        let context = Context(schema: schema, scalars: self.scalars)

        let subscription = schema.operations.first { $0.isSubscription }?.type.name

        // Code Parts
        let operations = schema.operations.map { $0.declaration() }
        let objectDefinitions = try schema.objects.map { object in
            try object.declaration(
                objects: schema.objects,
                context: context,
                alias: object.name != subscription
            )
        }

        let staticFieldSelection = try schema.objects.map { object in
            try object.statics(context: context)
        }

        let interfaceDefinitions = try schema.interfaces.map {
            try $0.declaration(objects: schema.objects, context: context)
        }

        let unionDefinitions = try schema.unions.map {
            try $0.declaration(objects: schema.objects, context: context)
        }

        let enumDefinitions = schema.enums.map { $0.declaration }

        let inputObjectDefinitions = try schema.inputObjects.map {
            try $0.declaration(context: context)
        }

        let header = """

        // This file was auto-generated using maticzav/swift-graphql. DO NOT EDIT MANUALLY!
        """

        let fileData: [FileData] = [
            FileData(
                filename: "Operations.swift",
                contents: """
                \(header)
                import Foundation
                import GraphQL
                import SwiftGraphQL


                public enum Operations {}
                \(operations.lines)
                """
            ),
            FileData(
                filename: "Objects.swift",
                contents: """
                \(header)
                import Foundation
                import GraphQL
                import SwiftGraphQL


                public enum Objects {}
                \(objectDefinitions.lines)
                \(staticFieldSelection.lines)
                """
            ),
            FileData(
                filename: "Interfaces.swift",
                contents: """
                \(header)
                import Foundation
                import GraphQL
                import SwiftGraphQL


                public enum Interfaces {}
                \(interfaceDefinitions.lines)
                """
            ),
            FileData(
                filename: "Unions.swift",
                contents: """
                \(header)
                import Foundation
                import GraphQL
                import SwiftGraphQL


                public enum Unions {}
                \(unionDefinitions.lines)
                """
            ),
            FileData(
                filename: "Enums.swift",
                contents: """
                \(header)
                import Foundation
                import GraphQL
                import SwiftGraphQL


                public enum Enums {}
                \(enumDefinitions.lines)

                """
            ),
            FileData(
                filename: "InputObjects.swift",
                contents: """
                \(header)
                import Foundation
                import GraphQL
                import SwiftGraphQL

                /// Utility pointer to InputObjects.
                public typealias Inputs = InputObjects

                public enum InputObjects {}
                \(inputObjectDefinitions.lines)

                """
            ),
        ]


        let formatted = try fileData.map({
            FileData(filename: $0.filename, contents: try $0.contents.format())
        })
        return formatted
    }
}

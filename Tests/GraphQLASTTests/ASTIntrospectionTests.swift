@testable import GraphQLAST
import XCTest

final class ASTIntrospectionTests: XCTestCase {
    /// Test that it's possible to load schema from a URL.
    func testLoadSchemaFromURL() async throws {
        let url = URL(string: "http://127.0.0.1:4000/graphql")!
        let schema = try await Schema(from: url)

        /* Tests */

        XCTAssertNotNil(schema)
    }
}

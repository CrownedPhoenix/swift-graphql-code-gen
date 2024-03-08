import Foundation

/*
 We use the common introspection Query to construct the library.
 You can find remaining utility types that represent the result
 of the schema introspection inside AST folder.

 I've namespaced every GraphQL and GraphQL schema related values
 and functions to GraphQL enum.
 */

// MARK: - Introspection Query

/// IntrospectionQuery that you should use to fetch data.
///
/// - Note: If you use a different introspection query, GraphQLAST might not be able to
///         correctly parse it.
public let introspectionQuery: String = """
query IntrospectionQuery($includeDeprecated: Boolean = true) {
    __schema {
        queryType { name }
        mutationType { name }
        subscriptionType { name }
        types {
        ...FullType
        }
    }
}

fragment FullType on __Type {
    kind
    name
    description
    fields(includeDeprecated: $includeDeprecated) {
        ...Field
    }
    inputFields {
        ...InputValue
    }
    interfaces {
        ...TypeRef
    }
    enumValues(includeDeprecated: $includeDeprecated) {
        ...EnumValue
    }
    possibleTypes {
        ...TypeRef
    }
}

fragment Field on __Field {
    name
    description
    args {
        ...InputValue
    }
    type {
        ...TypeRef
    }
    isDeprecated
    deprecationReason
}

fragment InputValue on __InputValue {
    name
    description
    type {
        ...TypeRef
    }
    defaultValue
}

fragment EnumValue on __EnumValue {
    name
    description
    isDeprecated
    deprecationReason
}



fragment TypeRef on __Type {
    kind
    name
    ofType {
        kind
        name
        ofType {
            kind
            name
            ofType {
                kind
                name
                ofType {
                    kind
                    name
                    ofType {
                        kind
                        name
                        ofType {
                            kind
                            name
                            ofType {
                                kind
                                name
                            }
                        }
                    }
                }
            }
        }
    }
}
"""

// MARK: - Parser

/// Decodes the received schema representation into Swift abstract type.
public func parse(_ data: Data) throws -> Schema {
    let decoder = JSONDecoder()
    let result = try decoder.decode(Reponse<IntrospectionQuery>.self, from: data)

    return result.data.schema
}

// MARK: - Internals

/// Represents a GraphQL response.
private struct Reponse<T: Decodable>: Decodable {
    public let data: T
}

extension Reponse: Equatable where T: Equatable {}

/// Represents introspection query return type in GraphQL response.
private struct IntrospectionQuery: Decodable, Equatable {
    public let schema: Schema

    enum CodingKeys: String, CodingKey {
        case schema = "__schema"
    }
}

// MARK: - Loader

/// Fetches a schema from the provided endpoint using introspection query.
func fetch(from endpoint: URL, withHeaders headers: [String: String] = [:]) async throws -> Data {
    /* Compose a request. */
    var request = URLRequest(url: endpoint)

    for header in headers {
        request.setValue(header.value, forHTTPHeaderField: header.key)
    }

    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("*/*", forHTTPHeaderField: "Accept")
    request.httpMethod = "POST"

    let payload: [String: Any] = [
        "query": introspectionQuery,
        "variables": [String: Any](),
        "operationName": "IntrospectionQuery"
    ]

    request.httpBody = try! JSONSerialization.data(
        withJSONObject: payload,
        options: JSONSerialization.WritingOptions()
    )

    /* Load the schema. */
    return try! await URLSession.shared.data(for: request).0
}

public enum IntrospectionError: Error {

    /// There was an error during the execution.
    case error(Error)

    /// Request received a bad status code from the server.
    case statusCode(Int)

    /// We don;t know what caused the error, but something unexpected happened.
    case unknown

    /// Error that signifies that there's no content at the provided file path.
    case emptyfile
}

// MARK: - Extension

public extension Schema {

    /// Downloads a schema from the provided endpoint or a local file.
    ///
    /// - NOTE: The function is going to load from the local path if the URL is missing a scheme or has a `file` scheme.
    init(from endpoint: URL, withHeaders headers: [String: String] = [:]) async throws {

        let introspection: Data
        if endpoint.isFileURL {
            introspection = try Data(contentsOf: endpoint)
        } else {
            introspection = try await fetch(from: endpoint, withHeaders: headers)
        }

        self = try parse(introspection)
    }
}

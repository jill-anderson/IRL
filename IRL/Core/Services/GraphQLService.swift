import Foundation
import Amplify

/// Service responsible for executing GraphQL queries, mutations, and subscriptions
class GraphQLService {

    // MARK: - Singleton

    static let shared = GraphQLService()

    private init() {}

    // MARK: - Query Operations

    /// Execute a GraphQL query
    /// - Parameters:
    ///   - query: GraphQL query string
    ///   - variables: Query variables
    /// - Returns: Dictionary containing the query result
    func query(query: String, variables: [String: Any] = [:]) async throws -> [String: Any] {
        let request = GraphQLRequest<String>(
            document: query,
            variables: variables.isEmpty ? nil : variables,
            responseType: String.self
        )

        let result = try await Amplify.API.query(request: request)

        switch result {
        case .success(let jsonString):
            guard let data = jsonString.data(using: .utf8),
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let dataDict = json["data"] as? [String: Any] else {
                throw NSError(domain: "GraphQLService", code: -1,
                             userInfo: [NSLocalizedDescriptionKey: "Invalid GraphQL response"])
            }
            return dataDict

        case .failure(let error):
            throw error
        }
    }

    // MARK: - Mutation Operations

    /// Execute a GraphQL mutation
    /// - Parameters:
    ///   - mutation: GraphQL mutation string
    ///   - variables: Mutation variables
    /// - Returns: Dictionary containing the mutation result
    func mutate(mutation: String, variables: [String: Any] = [:]) async throws -> [String: Any] {
        let request = GraphQLRequest<String>(
            document: mutation,
            variables: variables.isEmpty ? nil : variables,
            responseType: String.self
        )

        let result = try await Amplify.API.mutate(request: request)

        switch result {
        case .success(let jsonString):
            guard let data = jsonString.data(using: .utf8),
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let dataDict = json["data"] as? [String: Any] else {
                throw NSError(domain: "GraphQLService", code: -1,
                             userInfo: [NSLocalizedDescriptionKey: "Invalid GraphQL response"])
            }
            return dataDict

        case .failure(let error):
            throw error
        }
    }

    // MARK: - Subscription Operations

    /// Subscribe to a GraphQL subscription
    /// - Parameters:
    ///   - subscription: GraphQL subscription string
    ///   - variables: Subscription variables
    ///   - onUpdate: Callback when subscription receives an update
    /// - Returns: Subscription task that can be cancelled
    func subscribe(
        subscription: String,
        variables: [String: Any] = [:],
        onUpdate: @escaping ([String: Any]) -> Void
    ) -> Task<Void, Never> {
        Task {
            let request = GraphQLRequest<String>(
                document: subscription,
                variables: variables.isEmpty ? nil : variables,
                responseType: String.self
            )

            let subscription = Amplify.API.subscribe(request: request)

            do {
                for try await subscriptionEvent in subscription {
                    switch subscriptionEvent {
                    case .connection(let subscriptionConnectionState):
                        print("Subscription connection state: \(subscriptionConnectionState)")

                    case .data(let result):
                        switch result {
                        case .success(let jsonString):
                            if let data = jsonString.data(using: .utf8),
                               let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                               let dataDict = json["data"] as? [String: Any] {
                                onUpdate(dataDict)
                            }
                        case .failure(let error):
                            print("Subscription error: \(error)")
                        }
                    }
                }
            } catch {
                print("Subscription failed: \(error)")
            }
        }
    }
}

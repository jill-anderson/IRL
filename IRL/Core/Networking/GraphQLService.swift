import Foundation
import Combine

/// Service responsible for GraphQL API communication with AWS AppSync
class GraphQLService: ObservableObject {

    // MARK: - Properties

    private let apiEndpoint: String = "" // TODO: Get from amplifyconfiguration.json
    private let apiKey: String? = nil // For public API access if needed
    private var authToken: String? // Cognito JWT token

    // MARK: - Singleton

    static let shared = GraphQLService()

    private init() {}

    // MARK: - Query Operations

    /// Execute a GraphQL query
    /// - Parameters:
    ///   - query: GraphQL query string
    ///   - variables: Query variables dictionary
    /// - Returns: Decoded response data
    func query<T: Decodable>(
        _ query: String,
        variables: [String: Any]? = nil
    ) async throws -> T {
        let request = try buildRequest(
            query: query,
            variables: variables,
            operationType: .query
        )

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NSError(domain: "GraphQLService", code: -1,
                         userInfo: [NSLocalizedDescriptionKey: "Query failed"])
        }

        // TODO: Parse GraphQL response
        // Handle errors from GraphQL response
        // Decode data to type T

        throw NSError(domain: "GraphQLService", code: -1,
                     userInfo: [NSLocalizedDescriptionKey: "Query not yet implemented"])
    }

    // MARK: - Mutation Operations

    /// Execute a GraphQL mutation
    /// - Parameters:
    ///   - mutation: GraphQL mutation string
    ///   - variables: Mutation variables dictionary
    /// - Returns: Decoded response data
    func mutate<T: Decodable>(
        _ mutation: String,
        variables: [String: Any]? = nil
    ) async throws -> T {
        let request = try buildRequest(
            query: mutation,
            variables: variables,
            operationType: .mutation
        )

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NSError(domain: "GraphQLService", code: -1,
                         userInfo: [NSLocalizedDescriptionKey: "Mutation failed"])
        }

        // TODO: Parse GraphQL response
        // Handle errors from GraphQL response
        // Decode data to type T

        throw NSError(domain: "GraphQLService", code: -1,
                     userInfo: [NSLocalizedDescriptionKey: "Mutation not yet implemented"])
    }

    // MARK: - Subscription Operations

    /// Subscribe to a GraphQL subscription
    /// - Parameters:
    ///   - subscription: GraphQL subscription string
    ///   - variables: Subscription variables dictionary
    ///   - onData: Callback when data is received
    /// - Returns: Subscription object that can be cancelled
    func subscribe<T: Decodable>(
        _ subscription: String,
        variables: [String: Any]? = nil,
        onData: @escaping (T) -> Void
    ) -> AnyCancellable {
        // TODO: Implement WebSocket subscription to AppSync
        // 1. Establish WebSocket connection
        // 2. Send subscription message
        // 3. Handle incoming messages
        // 4. Decode and call onData callback
        // 5. Return cancellable subscription

        // Placeholder
        return AnyCancellable {}
    }

    // MARK: - Request Building

    private enum OperationType: String {
        case query
        case mutation
        case subscription
    }

    /// Build URLRequest for GraphQL operation
    private func buildRequest(
        query: String,
        variables: [String: Any]?,
        operationType: OperationType
    ) throws -> URLRequest {
        guard let url = URL(string: apiEndpoint) else {
            throw NSError(domain: "GraphQLService", code: -1,
                         userInfo: [NSLocalizedDescriptionKey: "Invalid API endpoint"])
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Add authorization header
        if let token = authToken {
            request.setValue(token, forHTTPHeaderField: "Authorization")
        }

        // Build request body
        var body: [String: Any] = ["query": query]
        if let variables = variables {
            body["variables"] = variables
        }

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        return request
    }

    // MARK: - Authentication

    /// Update authentication token
    /// - Parameter token: JWT token from Cognito
    func setAuthToken(_ token: String) {
        self.authToken = token
    }

    /// Clear authentication token
    func clearAuthToken() {
        self.authToken = nil
    }

    // MARK: - Response Models

    struct GraphQLResponse<T: Decodable>: Decodable {
        let data: T?
        let errors: [GraphQLError]?
    }

    struct GraphQLError: Decodable, Error {
        let message: String
        let locations: [Location]?
        let path: [String]?

        struct Location: Decodable {
            let line: Int
            let column: Int
        }
    }
}

// MARK: - Query/Mutation Builders

extension GraphQLService {

    /// Build query for fetching user by ID
    static func getUserQuery(userId: String) -> String {
        return """
        query GetUser($id: ID!) {
            getUser(id: $id) {
                id
                email
                username
                displayName
                bio
                profilePhotoUrl
                birthDate
                gender
                interestedIn
                locationPrivacy
                lastActiveAt
                createdAt
                updatedAt
            }
        }
        """
    }

    /// Build query for getting users at location
    static func getUsersAtLocationQuery() -> String {
        return """
        query GetUsersAtLocation($locationId: ID!, $limit: Int) {
            getUsersAtLocation(locationId: $locationId, limit: $limit) {
                id
                displayName
                username
                bio
                profilePhotoUrl
                gender
            }
        }
        """
    }

    /// Build mutation for auto check-in
    static func autoCheckInMutation() -> String {
        return """
        mutation AutoCheckIn($locationId: ID!) {
            autoCheckIn(locationId: $locationId) {
                id
                userId
                locationId
                checkInTime
                status
                autoCheckIn
            }
        }
        """
    }

    /// Build mutation for sending message
    static func sendMessageMutation() -> String {
        return """
        mutation SendMessage($recipientId: ID!, $content: String!) {
            sendMessage(recipientId: $recipientId, content: $content) {
                message {
                    id
                    conversationId
                    senderId
                    recipientId
                    content
                    timestamp
                    status
                }
                conversation {
                    id
                    lastMessageText
                    lastMessageTime
                    unreadCount1
                    unreadCount2
                }
            }
        }
        """
    }

    /// Build subscription for check-ins at location
    static func onCheckInAtLocationSubscription() -> String {
        return """
        subscription OnCheckInAtLocation($locationId: ID!) {
            onCheckInAtLocation(locationId: $locationId) {
                id
                userId
                checkInTime
                user {
                    id
                    displayName
                    profilePhotoUrl
                }
            }
        }
        """
    }

    /// Build subscription for new messages
    static func onNewMessageSubscription() -> String {
        return """
        subscription OnNewMessage($conversationId: ID!) {
            onNewMessage(conversationId: $conversationId) {
                id
                conversationId
                senderId
                recipientId
                content
                timestamp
                status
            }
        }
        """
    }
}

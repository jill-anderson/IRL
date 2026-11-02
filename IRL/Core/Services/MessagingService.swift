import Foundation
import Combine
import Amplify

/// Service responsible for managing conversations and messages
class MessagingService: ObservableObject {

    // MARK: - Published Properties

    @Published var conversations: [Conversation] = []
    @Published var messages: [String: [Message]] = [:] // conversationId -> messages
    @Published var isLoading: Bool = false
    @Published var error: Error?

    // MARK: - Private Properties

    private var cancellables = Set<AnyCancellable>()
    private var activeSubscriptions: Set<String> = [] // conversationIds being monitored
    private let graphQLService = GraphQLService.shared

    // MARK: - Singleton

    static let shared = MessagingService()

    private init() {
        fetchConversations()
    }

    // MARK: - Conversation Operations

    /// Fetch all conversations for current user
    func fetchConversations() {
        Task {
            do {
                isLoading = true
                defer { isLoading = false }

                guard let userId = AuthenticationService.shared.getCurrentUserId() else {
                    return
                }

                // Query for conversations where user is participant1
                let query1 = """
                query ListConversations($filter: ModelConversationFilterInput) {
                    listConversations(filter: $filter) {
                        items {
                            id
                            participant1Id
                            participant2Id
                            participant1Name
                            participant2Name
                            lastMessageText
                            lastMessageTime
                            unreadCount1
                            unreadCount2
                        }
                    }
                }
                """

                let filter1 = ["participant1Id": ["eq": userId]]
                let variables1 = ["filter": filter1]
                let result1 = try await graphQLService.query(query: query1, variables: variables1)

                // Query for conversations where user is participant2
                let filter2 = ["participant2Id": ["eq": userId]]
                let variables2 = ["filter": filter2]
                let result2 = try await graphQLService.query(query: query1, variables: variables2)

                // Parse and merge results
                var allConversations: [Conversation] = []

                if let items1 = result1["listConversations"] as? [String: Any],
                   let conversations1 = items1["items"] as? [[String: Any]] {
                    allConversations.append(contentsOf: conversations1.compactMap { try? parseConversation($0) })
                }

                if let items2 = result2["listConversations"] as? [String: Any],
                   let conversations2 = items2["items"] as? [[String: Any]] {
                    allConversations.append(contentsOf: conversations2.compactMap { try? parseConversation($0) })
                }

                // Sort by last message time
                allConversations.sort { conv1, conv2 in
                    guard let time1 = conv1.lastMessageTime, let time2 = conv2.lastMessageTime else {
                        return false
                    }
                    return time1 > time2
                }

                await MainActor.run {
                    self.conversations = allConversations
                }

            } catch {
                self.error = error
            }
        }
    }

    /// Fetch messages for a specific conversation
    /// - Parameters:
    ///   - conversationId: ID of the conversation
    ///   - limit: Maximum number of messages to fetch
    ///   - nextToken: Pagination token
    /// - Returns: Array of messages
    func fetchMessages(
        conversationId: String,
        limit: Int = 50,
        nextToken: String? = nil
    ) async throws -> [Message] {
        isLoading = true
        defer { isLoading = false }

        let query = """
        query ListMessages($filter: ModelMessageFilterInput, $limit: Int) {
            listMessages(filter: $filter, limit: $limit) {
                items {
                    id
                    conversationId
                    senderId
                    recipientId
                    content
                    timestamp
                    status
                }
            }
        }
        """

        let filter = ["conversationId": ["eq": conversationId]]
        let variables: [String: Any] = [
            "filter": filter,
            "limit": limit
        ]

        let result = try await graphQLService.query(query: query, variables: variables)

        guard let items = result["listMessages"] as? [String: Any],
              let messagesData = items["items"] as? [[String: Any]] else {
            return []
        }

        let fetchedMessages = messagesData.compactMap { try? parseMessage($0) }

        // Sort by timestamp (oldest first)
        let sortedMessages = fetchedMessages.sorted { $0.timestamp < $1.timestamp }

        // Cache messages
        await MainActor.run {
            self.messages[conversationId] = sortedMessages
        }

        return sortedMessages
    }

    /// Send a message to another user
    /// - Parameters:
    ///   - recipientId: ID of the recipient user
    ///   - content: Message text content
    /// - Returns: Created message object
    func sendMessage(to recipientId: String, content: String) async throws -> Message {
        guard !content.trimmed.isEmpty else {
            throw NSError(domain: "MessagingService", code: -1,
                         userInfo: [NSLocalizedDescriptionKey: "Message cannot be empty"])
        }

        guard let senderId = AuthenticationService.shared.getCurrentUserId() else {
            throw NSError(domain: "MessagingService", code: -1,
                         userInfo: [NSLocalizedDescriptionKey: "No authenticated user"])
        }

        isLoading = true
        defer { isLoading = false }

        // Find or create conversation
        var conversation = getConversation(with: recipientId)
        var conversationId: String

        if let existingConversation = conversation {
            conversationId = existingConversation.id
        } else {
            // Create new conversation
            conversationId = UUID().uuidString
            conversation = Conversation(
                id: conversationId,
                participant1Id: senderId,
                participant2Id: recipientId,
                participant1Name: AuthenticationService.shared.currentUser?.displayName ?? "",
                participant2Name: "", // Will be filled by backend
                lastMessageText: content,
                lastMessageTime: Date(),
                unreadCount1: 0,
                unreadCount2: 1
            )
        }

        // Create message
        let mutation = """
        mutation CreateMessage($input: CreateMessageInput!) {
            createMessage(input: $input) {
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

        let input: [String: Any] = [
            "id": UUID().uuidString,
            "conversationId": conversationId,
            "senderId": senderId,
            "recipientId": recipientId,
            "content": content,
            "timestamp": ISO8601DateFormatter().string(from: Date()),
            "status": Message.MessageStatus.sent.rawValue.uppercased()
        ]

        let variables = ["input": input]
        let result = try await graphQLService.mutate(mutation: mutation, variables: variables)

        guard let messageData = result["createMessage"] as? [String: Any],
              let message = try? parseMessage(messageData) else {
            throw NSError(domain: "MessagingService", code: -1,
                         userInfo: [NSLocalizedDescriptionKey: "Failed to send message"])
        }

        // Update local messages cache
        await MainActor.run {
            var currentMessages = self.messages[conversationId] ?? []
            currentMessages.append(message)
            self.messages[conversationId] = currentMessages

            // Update conversation list
            if let index = self.conversations.firstIndex(where: { $0.id == conversationId }) {
                self.conversations[index].lastMessageText = content
                self.conversations[index].lastMessageTime = message.timestamp
            } else if let newConv = conversation {
                self.conversations.insert(newConv, at: 0)
            }
        }

        return message
    }

    /// Mark messages in a conversation as read
    /// - Parameter conversationId: ID of the conversation
    func markAsRead(conversationId: String) async throws {
        // TODO: Call GraphQL mutation markMessagesAsRead
        // 1. Execute mutation
        // 2. Update local conversation unread count

        throw NSError(domain: "MessagingService", code: -1,
                     userInfo: [NSLocalizedDescriptionKey: "Mark as read not yet implemented"])
    }

    // MARK: - Real-time Subscriptions

    /// Subscribe to new messages in a conversation
    /// - Parameter conversationId: ID of the conversation
    func subscribeToMessages(conversationId: String) {
        guard !activeSubscriptions.contains(conversationId) else { return }

        // TODO: Subscribe to GraphQL subscription onNewMessage
        // 1. Create subscription for conversationId
        // 2. Update messages array when new message arrives
        // 3. Update message status (delivered, read)

        activeSubscriptions.insert(conversationId)

        // Fetch initial messages
        Task {
            do {
                let fetchedMessages = try await fetchMessages(conversationId: conversationId)
                await MainActor.run {
                    messages[conversationId] = fetchedMessages
                }
            } catch {
                await MainActor.run {
                    self.error = error
                }
            }
        }
    }

    /// Unsubscribe from conversation messages
    /// - Parameter conversationId: ID of the conversation
    func unsubscribeFromMessages(conversationId: String) {
        // TODO: Cancel GraphQL subscription
        activeSubscriptions.remove(conversationId)
    }

    /// Subscribe to all conversation updates for current user
    func subscribeToConversations() {
        guard let userId = AuthenticationService.shared.getCurrentUserId() else { return }

        // TODO: Subscribe to GraphQL subscription onConversationUpdate
        // 1. Subscribe to conversation updates for userId
        // 2. Update conversations array when conversation changes
        // 3. Update unread counts
    }

    /// Unsubscribe from all conversation updates
    func unsubscribeFromConversations() {
        // TODO: Cancel conversation subscriptions
    }

    // MARK: - Helper Methods

    /// Get conversation with a specific user
    /// - Parameter userId: ID of the other user
    /// - Returns: Conversation if exists
    func getConversation(with userId: String) -> Conversation? {
        guard let currentUserId = AuthenticationService.shared.getCurrentUserId() else {
            return nil
        }

        return conversations.first { conversation in
            (conversation.participant1Id == currentUserId && conversation.participant2Id == userId) ||
            (conversation.participant2Id == currentUserId && conversation.participant1Id == userId)
        }
    }

    /// Get messages for a conversation
    /// - Parameter conversationId: ID of the conversation
    /// - Returns: Array of messages
    func getMessages(for conversationId: String) -> [Message] {
        return messages[conversationId] ?? []
    }

    /// Get total unread message count
    var totalUnreadCount: Int {
        guard let currentUserId = AuthenticationService.shared.getCurrentUserId() else {
            return 0
        }

        return conversations.reduce(0) { total, conversation in
            total + conversation.unreadCount(for: currentUserId)
        }
    }

    /// Clear all cached data
    func clearCache() {
        conversations.removeAll()
        messages.removeAll()
        activeSubscriptions.removeAll()
    }

    // MARK: - Parsing Helpers

    private func parseConversation(_ data: [String: Any]) throws -> Conversation {
        guard let id = data["id"] as? String,
              let participant1Id = data["participant1Id"] as? String,
              let participant2Id = data["participant2Id"] as? String,
              let participant1Name = data["participant1Name"] as? String,
              let participant2Name = data["participant2Name"] as? String,
              let unreadCount1 = data["unreadCount1"] as? Int,
              let unreadCount2 = data["unreadCount2"] as? Int else {
            throw NSError(domain: "MessagingService", code: -1,
                         userInfo: [NSLocalizedDescriptionKey: "Invalid conversation data"])
        }

        let lastMessageText = data["lastMessageText"] as? String
        var lastMessageTime: Date?

        if let timeString = data["lastMessageTime"] as? String {
            lastMessageTime = ISO8601DateFormatter().date(from: timeString)
        }

        return Conversation(
            id: id,
            participant1Id: participant1Id,
            participant2Id: participant2Id,
            participant1Name: participant1Name,
            participant2Name: participant2Name,
            lastMessageText: lastMessageText,
            lastMessageTime: lastMessageTime,
            unreadCount1: unreadCount1,
            unreadCount2: unreadCount2
        )
    }

    private func parseMessage(_ data: [String: Any]) throws -> Message {
        guard let id = data["id"] as? String,
              let conversationId = data["conversationId"] as? String,
              let senderId = data["senderId"] as? String,
              let recipientId = data["recipientId"] as? String,
              let content = data["content"] as? String,
              let timestampString = data["timestamp"] as? String,
              let statusString = data["status"] as? String else {
            throw NSError(domain: "MessagingService", code: -1,
                         userInfo: [NSLocalizedDescriptionKey: "Invalid message data"])
        }

        guard let timestamp = ISO8601DateFormatter().date(from: timestampString) else {
            throw NSError(domain: "MessagingService", code: -1,
                         userInfo: [NSLocalizedDescriptionKey: "Invalid timestamp"])
        }

        let status = Message.MessageStatus(rawValue: statusString.lowercased()) ?? .sent

        return Message(
            id: id,
            conversationId: conversationId,
            senderId: senderId,
            recipientId: recipientId,
            content: content,
            timestamp: timestamp,
            status: status
        )
    }
}

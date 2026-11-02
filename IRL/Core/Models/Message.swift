import Foundation

struct Message: Codable, Identifiable {
    let id: String
    var conversationId: String
    var senderId: String
    var recipientId: String
    var content: String
    var timestamp: Date
    var status: MessageStatus

    enum MessageStatus: String, Codable {
        case sent = "SENT"
        case delivered = "DELIVERED"
        case read = "READ"
    }

    var timeString: String {
        let formatter = DateFormatter()
        let calendar = Calendar.current

        if calendar.isDateInToday(timestamp) {
            formatter.dateFormat = "h:mm a"
        } else if calendar.isDateInYesterday(timestamp) {
            return "Yesterday"
        } else if calendar.component(.year, from: timestamp) == calendar.component(.year, from: Date()) {
            formatter.dateFormat = "MMM d"
        } else {
            formatter.dateFormat = "MMM d, yyyy"
        }

        return formatter.string(from: timestamp)
    }
}

struct Conversation: Codable, Identifiable {
    let id: String
    var participant1Id: String
    var participant2Id: String
    var participant1Name: String
    var participant2Name: String
    var participant1Photo: String?
    var participant2Photo: String?
    var lastMessageText: String?
    var lastMessageTime: Date?
    var lastMessageSender: String?
    var unreadCount1: Int
    var unreadCount2: Int
    var createdAt: Date
    var updatedAt: Date

    func otherParticipant(currentUserId: String) -> (id: String, name: String, photo: String?) {
        if participant1Id == currentUserId {
            return (participant2Id, participant2Name, participant2Photo)
        } else {
            return (participant1Id, participant1Name, participant1Photo)
        }
    }

    func unreadCount(for userId: String) -> Int {
        return userId == participant1Id ? unreadCount1 : unreadCount2
    }

    var lastMessageTimeString: String? {
        guard let lastMessageTime = lastMessageTime else { return nil }

        let formatter = DateFormatter()
        let calendar = Calendar.current

        if calendar.isDateInToday(lastMessageTime) {
            formatter.dateFormat = "h:mm a"
        } else if calendar.isDateInYesterday(lastMessageTime) {
            return "Yesterday"
        } else if calendar.component(.year, from: lastMessageTime) == calendar.component(.year, from: Date()) {
            formatter.dateFormat = "MMM d"
        } else {
            formatter.dateFormat = "MMM d, yyyy"
        }

        return formatter.string(from: lastMessageTime)
    }
}

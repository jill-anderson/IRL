import SwiftUI

struct ConversationRow: View {
    var conversation: Conversation
    var currentUserId: String

    var body: some View {
        HStack(spacing: Spacing.md) {
            // Profile Photo with unread badge
            ZStack(alignment: .topTrailing) {
                let otherUser = conversation.otherParticipant(currentUserId: currentUserId)

                ProfileImageView(
                    imageUrl: otherUser.photo,
                    size: 56
                )

                if conversation.unreadCount(for: currentUserId) > 0 {
                    ZStack {
                        Circle()
                            .fill(Color.theme.error)
                            .frame(width: 20, height: 20)

                        Text("\(conversation.unreadCount(for: currentUserId))")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .offset(x: 4, y: -4)
                }
            }

            // Conversation Info
            VStack(alignment: .leading, spacing: Spacing.xxs) {
                HStack {
                    Text(conversation.otherParticipant(currentUserId: currentUserId).name)
                        .font(.theme.bodyBold)
                        .foregroundColor(.theme.primaryText)

                    Spacer()

                    if let timeString = conversation.lastMessageTimeString {
                        Text(timeString)
                            .font(.theme.caption2)
                            .foregroundColor(.theme.tertiaryText)
                    }
                }

                if let lastMessage = conversation.lastMessageText {
                    HStack(spacing: Spacing.xxs) {
                        if conversation.lastMessageSender == currentUserId {
                            Image(systemName: "checkmark")
                                .font(.system(size: 10))
                                .foregroundColor(.theme.secondary)
                        }

                        Text(lastMessage)
                            .font(.theme.caption)
                            .foregroundColor(
                                conversation.unreadCount(for: currentUserId) > 0 ?
                                    .theme.primaryText : .theme.secondaryText
                            )
                            .lineLimit(1)
                    }
                    .fontWeight(
                        conversation.unreadCount(for: currentUserId) > 0 ? .semibold : .regular
                    )
                }
            }
        }
        .padding(.vertical, Spacing.xs)
    }
}

#Preview {
    List {
        ConversationRow(
            conversation: Conversation(
                id: "1",
                participant1Id: "user1",
                participant2Id: "user2",
                participant1Name: "John Doe",
                participant2Name: "Sarah Johnson",
                participant1Photo: nil,
                participant2Photo: nil,
                lastMessageText: "Hey! Great to meet you at the bar",
                lastMessageTime: Date().addingTimeInterval(-3600),
                lastMessageSender: "user2",
                unreadCount1: 2,
                unreadCount2: 0,
                createdAt: Date(),
                updatedAt: Date()
            ),
            currentUserId: "user1"
        )

        ConversationRow(
            conversation: Conversation(
                id: "2",
                participant1Id: "user1",
                participant2Id: "user3",
                participant1Name: "John Doe",
                participant2Name: "Mike Roberts",
                participant1Photo: nil,
                participant2Photo: nil,
                lastMessageText: "Sounds good! See you there",
                lastMessageTime: Date().addingTimeInterval(-86400),
                lastMessageSender: "user1",
                unreadCount1: 0,
                unreadCount2: 1,
                createdAt: Date(),
                updatedAt: Date()
            ),
            currentUserId: "user1"
        )
    }
}

import SwiftUI

struct MessageBubble: View {
    var message: Message
    var isFromCurrentUser: Bool

    var body: some View {
        HStack {
            if isFromCurrentUser {
                Spacer()
            }

            VStack(alignment: isFromCurrentUser ? .trailing : .leading, spacing: Spacing.xxs) {
                Text(message.content)
                    .font(.theme.body)
                    .foregroundColor(isFromCurrentUser ? .white : .theme.primaryText)
                    .padding(.horizontal, Spacing.md)
                    .padding(.vertical, Spacing.sm)
                    .background(
                        isFromCurrentUser ?
                            Color.theme.primary :
                            Color.theme.secondaryBackground
                    )
                    .cornerRadius(Spacing.cornerRadius, corners: isFromCurrentUser ?
                        [.topLeft, .topRight, .bottomLeft] :
                        [.topLeft, .topRight, .bottomRight]
                    )

                HStack(spacing: Spacing.xxs) {
                    Text(message.timeString)
                        .font(.theme.caption2)
                        .foregroundColor(.theme.tertiaryText)

                    if isFromCurrentUser {
                        Image(systemName: statusIcon(message.status))
                            .font(.system(size: 10))
                            .foregroundColor(statusColor(message.status))
                    }
                }
                .padding(.horizontal, Spacing.xs)
            }

            if !isFromCurrentUser {
                Spacer()
            }
        }
        .padding(.horizontal, Spacing.md)
    }

    private func statusIcon(_ status: Message.MessageStatus) -> String {
        switch status {
        case .sent: return "checkmark"
        case .delivered: return "checkmark.circle"
        case .read: return "checkmark.circle.fill"
        }
    }

    private func statusColor(_ status: Message.MessageStatus) -> Color {
        switch status {
        case .sent: return .theme.tertiaryText
        case .delivered: return .theme.secondaryText
        case .read: return .theme.primary
        }
    }
}

struct MessageInputView: View {
    @Binding var text: String
    var onSend: () -> Void

    var body: some View {
        HStack(spacing: Spacing.sm) {
            TextField("Message...", text: $text, axis: .vertical)
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, Spacing.sm)
                .background(Color.theme.secondaryBackground)
                .cornerRadius(Spacing.cornerRadius)
                .lineLimit(1...5)

            Button(action: {
                if !text.trimmed.isEmpty {
                    onSend()
                }
            }) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(
                        text.trimmed.isEmpty ?
                            .theme.tertiaryText :
                            .theme.primary
                    )
            }
            .disabled(text.trimmed.isEmpty)
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.sm)
        .background(Color.theme.background)
    }
}

#Preview {
    VStack(spacing: 20) {
        MessageBubble(
            message: Message(
                id: "1",
                conversationId: "conv1",
                senderId: "user1",
                recipientId: "user2",
                content: "Hey! Great meeting you at the bar earlier",
                timestamp: Date().addingTimeInterval(-300),
                status: .read
            ),
            isFromCurrentUser: true
        )

        MessageBubble(
            message: Message(
                id: "2",
                conversationId: "conv1",
                senderId: "user2",
                recipientId: "user1",
                content: "Yeah! That was fun. We should hang out again sometime",
                timestamp: Date().addingTimeInterval(-60),
                status: .delivered
            ),
            isFromCurrentUser: false
        )

        Spacer()

        MessageInputView(text: .constant(""), onSend: {})
    }
    .background(Color.theme.background)
}

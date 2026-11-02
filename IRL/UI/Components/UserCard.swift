import SwiftUI

struct UserCard: View {
    var user: User
    var checkInTime: Date?
    var showMessageButton: Bool = true
    var messageAction: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack(spacing: Spacing.md) {
                // Profile Photo
                ProfileImageView(
                    imageUrl: user.profilePhotoUrl,
                    size: 60
                )

                // User Info
                VStack(alignment: .leading, spacing: Spacing.xxs) {
                    Text(user.displayName)
                        .font(.theme.bodyBold)
                        .foregroundColor(.theme.primaryText)

                    Text("@\(user.username)")
                        .font(.theme.caption)
                        .foregroundColor(.theme.secondaryText)

                    if let checkInTime = checkInTime {
                        HStack(spacing: Spacing.xxs) {
                            Image(systemName: "clock")
                                .font(.system(size: 10))

                            Text("Checked in \(checkInTime.shortTimeAgoString)")
                                .font(.theme.caption2)
                        }
                        .foregroundColor(.theme.tertiaryText)
                    }
                }

                Spacer()

                // Gender Icon
                Image(systemName: genderIcon(user.gender))
                    .font(.system(size: 16))
                    .foregroundColor(.theme.secondary)
            }

            // Bio
            if let bio = user.bio, !bio.isEmpty {
                Text(bio)
                    .font(.theme.caption)
                    .foregroundColor(.theme.secondaryText)
                    .lineLimit(2)
            }

            // Message Button
            if showMessageButton, let messageAction = messageAction {
                PrimaryButton(title: "Send Message", action: messageAction)
                    .frame(height: 40)
            }
        }
        .padding(Spacing.md)
        .background(Color.theme.cardBackground)
        .cornerRadius(Spacing.cornerRadius)
        .shadow(color: Color.theme.shadow, radius: 4, x: 0, y: 2)
    }

    private func genderIcon(_ gender: User.Gender) -> String {
        switch gender {
        case .male: return "person"
        case .female: return "person.fill"
        case .nonBinary: return "person.2"
        case .other: return "person.circle"
        }
    }
}

struct CompactUserCard: View {
    var user: User
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.md) {
                ProfileImageView(
                    imageUrl: user.profilePhotoUrl,
                    size: 44
                )

                VStack(alignment: .leading, spacing: Spacing.xxs) {
                    Text(user.displayName)
                        .font(.theme.bodyBold)
                        .foregroundColor(.theme.primaryText)

                    if let bio = user.bio, !bio.isEmpty {
                        Text(bio)
                            .font(.theme.caption)
                            .foregroundColor(.theme.secondaryText)
                            .lineLimit(1)
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.theme.tertiaryText)
            }
            .padding(Spacing.md)
            .background(Color.theme.cardBackground)
            .cornerRadius(Spacing.cornerRadius)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    VStack(spacing: 16) {
        UserCard(
            user: User(
                id: "1",
                email: "sarah@example.com",
                username: "sarah_j",
                displayName: "Sarah Johnson",
                bio: "Love exploring new places and meeting new people!",
                profilePhotoKey: nil,
                profilePhotoUrl: nil,
                birthDate: Date(),
                gender: .female,
                interestedIn: [.male],
                locationPrivacy: .publicLocation,
                notificationPreferences: NotificationPreferences(),
                lastActiveAt: Date(),
                createdAt: Date(),
                updatedAt: Date()
            ),
            checkInTime: Date().addingTimeInterval(-300),
            messageAction: {}
        )

        CompactUserCard(
            user: User(
                id: "2",
                email: "mike@example.com",
                username: "mike_r",
                displayName: "Mike Roberts",
                bio: "Coffee enthusiast ☕️",
                profilePhotoKey: nil,
                profilePhotoUrl: nil,
                birthDate: Date(),
                gender: .male,
                interestedIn: [.female],
                locationPrivacy: .publicLocation,
                notificationPreferences: NotificationPreferences(),
                lastActiveAt: Date(),
                createdAt: Date(),
                updatedAt: Date()
            ),
            action: {}
        )
    }
    .padding()
}

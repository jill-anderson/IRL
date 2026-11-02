import SwiftUI

struct EmptyStateView: View {
    var icon: String
    var title: String
    var message: String
    var actionTitle: String?
    var action: (() -> Void)?

    var body: some View {
        VStack(spacing: Spacing.lg) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundColor(.theme.secondaryText)

            VStack(spacing: Spacing.xs) {
                Text(title)
                    .font(.theme.title3)
                    .foregroundColor(.theme.primaryText)

                Text(message)
                    .font(.theme.body)
                    .foregroundColor(.theme.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Spacing.xl)
            }

            if let actionTitle = actionTitle, let action = action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(.theme.bodyBold)
                        .foregroundColor(.white)
                        .frame(height: Spacing.buttonHeight)
                        .frame(maxWidth: 200)
                        .background(Color.theme.primary)
                        .cornerRadius(Spacing.cornerRadius)
                }
                .padding(.top, Spacing.sm)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.theme.background)
    }
}

// Predefined empty states
extension EmptyStateView {
    static func noCheckIns(action: @escaping () -> Void) -> EmptyStateView {
        EmptyStateView(
            icon: "location.slash",
            title: "No Check-ins Yet",
            message: "When you visit a bar or restaurant, you'll automatically be checked in and see other users here.",
            actionTitle: "Enable Location",
            action: action
        )
    }

    static func noUsers() -> EmptyStateView {
        EmptyStateView(
            icon: "person.3",
            title: "Nobody Here Yet",
            message: "Be the first one to check in at this location!",
            actionTitle: nil,
            action: nil
        )
    }

    static func noMessages() -> EmptyStateView {
        EmptyStateView(
            icon: "bubble.left.and.bubble.right",
            title: "No Messages",
            message: "Start a conversation with someone you've met at a location.",
            actionTitle: nil,
            action: nil
        )
    }

    static func noLocations() -> EmptyStateView {
        EmptyStateView(
            icon: "map",
            title: "No Nearby Locations",
            message: "There are no bars or restaurants nearby. Try moving to a different area.",
            actionTitle: nil,
            action: nil
        )
    }

    static func locationPermissionDenied(action: @escaping () -> Void) -> EmptyStateView {
        EmptyStateView(
            icon: "location.slash.fill",
            title: "Location Access Required",
            message: "IRL needs access to your location to automatically check you in at bars and restaurants.",
            actionTitle: "Open Settings",
            action: action
        )
    }
}

#Preview {
    VStack {
        EmptyStateView.noCheckIns(action: {})
    }
}

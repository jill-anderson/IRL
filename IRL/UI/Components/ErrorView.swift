import SwiftUI

struct ErrorView: View {
    var error: Error
    var retryAction: (() -> Void)?

    var body: some View {
        VStack(spacing: Spacing.lg) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.theme.error)

            VStack(spacing: Spacing.xs) {
                Text("Something Went Wrong")
                    .font(.theme.title3)
                    .foregroundColor(.theme.primaryText)

                Text(error.localizedDescription)
                    .font(.theme.body)
                    .foregroundColor(.theme.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Spacing.xl)
            }

            if let retryAction = retryAction {
                PrimaryButton(title: "Try Again", action: retryAction)
                    .frame(maxWidth: 200)
            }
        }
        .padding(Spacing.xl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.theme.background)
    }
}

struct InlineErrorView: View {
    var message: String

    var body: some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: "exclamationmark.circle.fill")
                .foregroundColor(.theme.error)

            Text(message)
                .font(.theme.caption)
                .foregroundColor(.theme.error)
        }
        .padding(Spacing.sm)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.theme.error.opacity(0.1))
        .cornerRadius(Spacing.smallCornerRadius)
    }
}

struct ToastView: View {
    var message: String
    var type: ToastType = .info

    enum ToastType {
        case success, error, warning, info

        var icon: String {
            switch self {
            case .success: return "checkmark.circle.fill"
            case .error: return "xmark.circle.fill"
            case .warning: return "exclamationmark.triangle.fill"
            case .info: return "info.circle.fill"
            }
        }

        var color: Color {
            switch self {
            case .success: return .theme.success
            case .error: return .theme.error
            case .warning: return .theme.warning
            case .info: return .theme.info
            }
        }
    }

    var body: some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: type.icon)
                .foregroundColor(type.color)

            Text(message)
                .font(.theme.callout)
                .foregroundColor(.theme.primaryText)

            Spacer()
        }
        .padding(Spacing.md)
        .background(Color.theme.cardBackground)
        .cornerRadius(Spacing.cornerRadius)
        .shadow(color: Color.theme.shadow, radius: 8, x: 0, y: 2)
        .padding(.horizontal, Spacing.md)
    }
}

#Preview {
    VStack(spacing: 20) {
        ErrorView(
            error: NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Network connection failed"]),
            retryAction: {}
        )

        InlineErrorView(message: "Invalid email address")

        ToastView(message: "Check-in successful!", type: .success)
        ToastView(message: "Failed to send message", type: .error)
        ToastView(message: "Location permission required", type: .warning)
    }
}

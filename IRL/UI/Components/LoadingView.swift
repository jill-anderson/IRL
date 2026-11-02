import SwiftUI

struct LoadingView: View {
    var message: String = "Loading..."
    var showMessage: Bool = true

    var body: some View {
        VStack(spacing: Spacing.md) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .theme.primary))
                .scaleEffect(1.5)

            if showMessage {
                Text(message)
                    .font(.theme.callout)
                    .foregroundColor(.theme.secondaryText)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.theme.background.ignoresSafeArea())
    }
}

struct InlineLoadingView: View {
    var message: String = "Loading..."

    var body: some View {
        HStack(spacing: Spacing.sm) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .theme.primary))

            Text(message)
                .font(.theme.callout)
                .foregroundColor(.theme.secondaryText)
        }
        .padding(Spacing.md)
        .frame(maxWidth: .infinity)
    }
}

struct ButtonLoadingView: View {
    var body: some View {
        ProgressView()
            .progressViewStyle(CircularProgressViewStyle(tint: .white))
            .scaleEffect(0.9)
    }
}

#Preview {
    VStack(spacing: 20) {
        LoadingView()

        InlineLoadingView(message: "Loading users...")

        Button(action: {}) {
            ButtonLoadingView()
        }
        .buttonStyle(.borderedProminent)
    }
}

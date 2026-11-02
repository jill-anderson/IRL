import SwiftUI

struct PrimaryButton: View {
    var title: String
    var isLoading: Bool = false
    var isDisabled: Bool = false
    var action: () -> Void

    var body: some View {
        Button(action: {
            if !isLoading && !isDisabled {
                action()
            }
        }) {
            ZStack {
                if isLoading {
                    ButtonLoadingView()
                } else {
                    Text(title)
                        .font(.theme.bodyBold)
                        .foregroundColor(.white)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: Spacing.buttonHeight)
            .background(
                (isDisabled || isLoading) ?
                    Color.theme.primary.opacity(0.5) :
                    Color.theme.primary
            )
            .cornerRadius(Spacing.cornerRadius)
        }
        .disabled(isDisabled || isLoading)
    }
}

struct SecondaryButton: View {
    var title: String
    var isLoading: Bool = false
    var isDisabled: Bool = false
    var action: () -> Void

    var body: some View {
        Button(action: {
            if !isLoading && !isDisabled {
                action()
            }
        }) {
            ZStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .theme.primary))
                        .scaleEffect(0.9)
                } else {
                    Text(title)
                        .font(.theme.bodyBold)
                        .foregroundColor(.theme.primary)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: Spacing.buttonHeight)
            .background(Color.theme.secondaryBackground)
            .cornerRadius(Spacing.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: Spacing.cornerRadius)
                    .strokeBorder(Color.theme.primary, lineWidth: 1)
            )
        }
        .disabled(isDisabled || isLoading)
    }
}

#Preview {
    VStack(spacing: 20) {
        PrimaryButton(title: "Continue", action: {})

        PrimaryButton(title: "Loading...", isLoading: true, action: {})

        PrimaryButton(title: "Disabled", isDisabled: true, action: {})

        SecondaryButton(title: "Cancel", action: {})

        SecondaryButton(title: "Loading...", isLoading: true, action: {})
    }
    .padding()
}

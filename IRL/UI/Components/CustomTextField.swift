import SwiftUI

struct CustomTextField: View {
    var placeholder: String
    @Binding var text: String
    var icon: String? = nil
    var isSecure: Bool = false
    var keyboardType: UIKeyboardType = .default
    var textContentType: UITextContentType? = nil
    var autocapitalization: TextInputAutocapitalization = .sentences

    @State private var isSecureVisible: Bool = false

    var body: some View {
        HStack(spacing: Spacing.sm) {
            if let icon = icon {
                Image(systemName: icon)
                    .foregroundColor(.theme.secondaryText)
                    .frame(width: 20)
            }

            if isSecure && !isSecureVisible {
                SecureField(placeholder, text: $text)
                    .textContentType(textContentType)
                    .autocapitalization(autocapitalization)
            } else {
                TextField(placeholder, text: $text)
                    .keyboardType(keyboardType)
                    .textContentType(textContentType)
                    .autocapitalization(autocapitalization)
            }

            if isSecure {
                Button(action: {
                    isSecureVisible.toggle()
                }) {
                    Image(systemName: isSecureVisible ? "eye.slash" : "eye")
                        .foregroundColor(.theme.secondaryText)
                }
            }
        }
        .padding(Spacing.md)
        .background(Color.theme.secondaryBackground)
        .cornerRadius(Spacing.cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: Spacing.cornerRadius)
                .strokeBorder(Color.theme.separator, lineWidth: 1)
        )
    }
}

struct CustomTextEditor: View {
    var placeholder: String
    @Binding var text: String
    var height: CGFloat = 100

    var body: some View {
        ZStack(alignment: .topLeading) {
            if text.isEmpty {
                Text(placeholder)
                    .foregroundColor(.theme.tertiaryText)
                    .padding(.horizontal, Spacing.md + 4)
                    .padding(.vertical, Spacing.md + 8)
            }

            TextEditor(text: $text)
                .padding(Spacing.xs)
                .frame(height: height)
                .scrollContentBackground(.hidden)
        }
        .background(Color.theme.secondaryBackground)
        .cornerRadius(Spacing.cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: Spacing.cornerRadius)
                .strokeBorder(Color.theme.separator, lineWidth: 1)
        )
    }
}

#Preview {
    VStack(spacing: 20) {
        CustomTextField(
            placeholder: "Email",
            text: .constant(""),
            icon: "envelope",
            keyboardType: .emailAddress,
            textContentType: .emailAddress,
            autocapitalization: .never
        )

        CustomTextField(
            placeholder: "Password",
            text: .constant(""),
            icon: "lock",
            isSecure: true,
            textContentType: .password
        )

        CustomTextField(
            placeholder: "Username",
            text: .constant(""),
            icon: "person"
        )

        CustomTextEditor(
            placeholder: "Write your bio...",
            text: .constant(""),
            height: 120
        )
    }
    .padding()
}

import SwiftUI

extension Color {
    static let theme = ColorTheme()
}

struct ColorTheme {
    // Primary Colors
    let primary = Color("Primary", bundle: nil) ?? Color.blue
    let secondary = Color("Secondary", bundle: nil) ?? Color.purple
    let accent = Color("Accent", bundle: nil) ?? Color.pink

    // Background Colors
    let background = Color(uiColor: .systemBackground)
    let secondaryBackground = Color(uiColor: .secondarySystemBackground)
    let tertiaryBackground = Color(uiColor: .tertiarySystemBackground)

    // Text Colors
    let primaryText = Color(uiColor: .label)
    let secondaryText = Color(uiColor: .secondaryLabel)
    let tertiaryText = Color(uiColor: .tertiaryLabel)

    // System Colors
    let success = Color.green
    let warning = Color.orange
    let error = Color.red
    let info = Color.blue

    // Component Colors
    let cardBackground = Color(uiColor: .systemBackground)
    let separator = Color(uiColor: .separator)
    let shadow = Color.black.opacity(0.1)
}

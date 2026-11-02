import SwiftUI

extension Font {
    static let theme = Typography()
}

struct Typography {
    // Display
    let largeTitle = Font.largeTitle.weight(.bold)
    let title = Font.title.weight(.semibold)
    let title2 = Font.title2.weight(.semibold)
    let title3 = Font.title3.weight(.semibold)

    // Body
    let body = Font.body
    let bodyBold = Font.body.weight(.semibold)
    let callout = Font.callout
    let caption = Font.caption
    let caption2 = Font.caption2

    // Custom
    let headline = Font.headline
    let subheadline = Font.subheadline
    let footnote = Font.footnote
}

import SwiftUI

struct ProfileImageView: View {
    var imageUrl: String?
    var size: CGFloat = 50
    var placeholderIcon: String = "person.fill"

    var body: some View {
        ZStack {
            if let imageUrl = imageUrl, let url = URL(string: imageUrl) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        placeholderView
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure:
                        placeholderView
                    @unknown default:
                        placeholderView
                    }
                }
            } else {
                placeholderView
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .overlay(
            Circle()
                .strokeBorder(Color.theme.separator, lineWidth: 1)
        )
    }

    private var placeholderView: some View {
        ZStack {
            Color.theme.secondaryBackground

            Image(systemName: placeholderIcon)
                .font(.system(size: size * 0.5))
                .foregroundColor(.theme.tertiaryText)
        }
    }
}

struct ProfileImageView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            // With URL
            ProfileImageView(
                imageUrl: "https://via.placeholder.com/150",
                size: 80
            )

            // Without URL (placeholder)
            ProfileImageView(size: 80)

            // Small size
            ProfileImageView(size: 40)

            // Large size
            ProfileImageView(size: 120)
        }
        .padding()
    }
}

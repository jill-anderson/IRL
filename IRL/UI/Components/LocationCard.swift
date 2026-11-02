import SwiftUI

struct LocationCard: View {
    var location: Location
    var userCount: Int = 0
    var distance: String?
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.md) {
                // Location Icon
                ZStack {
                    RoundedRectangle(cornerRadius: Spacing.smallCornerRadius)
                        .fill(Color.theme.secondary.opacity(0.1))
                        .frame(width: 50, height: 50)

                    Image(systemName: location.type.icon)
                        .font(.system(size: 24))
                        .foregroundColor(.theme.secondary)
                }

                // Location Info
                VStack(alignment: .leading, spacing: Spacing.xxs) {
                    Text(location.name)
                        .font(.theme.bodyBold)
                        .foregroundColor(.theme.primaryText)
                        .lineLimit(1)

                    Text(location.type.displayName)
                        .font(.theme.caption)
                        .foregroundColor(.theme.secondaryText)

                    if let distance = distance {
                        Text(distance)
                            .font(.theme.caption2)
                            .foregroundColor(.theme.tertiaryText)
                    }
                }

                Spacer()

                // User Count Badge
                if userCount > 0 {
                    VStack(spacing: Spacing.xxs) {
                        Image(systemName: "person.2.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.theme.primary)

                        Text("\(userCount)")
                            .font(.theme.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.theme.primaryText)
                    }
                    .padding(.horizontal, Spacing.sm)
                    .padding(.vertical, Spacing.xs)
                    .background(Color.theme.primary.opacity(0.1))
                    .cornerRadius(Spacing.smallCornerRadius)
                }

                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.theme.tertiaryText)
            }
            .padding(Spacing.md)
            .background(Color.theme.cardBackground)
            .cornerRadius(Spacing.cornerRadius)
            .shadow(color: Color.theme.shadow, radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    VStack(spacing: 16) {
        LocationCard(
            location: Location(
                id: "1",
                name: "The Blue Moon Bar",
                type: .bar,
                address: "123 Main St",
                coordinate: Coordinate(latitude: 37.7749, longitude: -122.4194),
                geofenceId: "geo-1",
                radius: 100,
                createdAt: Date(),
                updatedAt: Date()
            ),
            userCount: 5,
            distance: "0.3 mi away",
            action: {}
        )

        LocationCard(
            location: Location(
                id: "2",
                name: "Pasta Paradise",
                type: .restaurant,
                address: "456 Oak Ave",
                coordinate: Coordinate(latitude: 37.7749, longitude: -122.4194),
                geofenceId: "geo-2",
                radius: 100,
                createdAt: Date(),
                updatedAt: Date()
            ),
            userCount: 0,
            distance: "0.5 mi away",
            action: {}
        )
    }
    .padding()
}

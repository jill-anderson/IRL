import Foundation

struct CheckIn: Codable, Identifiable {
    let id: String
    var userId: String
    var locationId: String
    var checkInTime: Date
    var checkOutTime: Date?
    var status: CheckInStatus
    var autoCheckIn: Bool
    var user: User?
    var location: Location?

    enum CheckInStatus: String, Codable {
        case active = "ACTIVE"
        case checkedOut = "CHECKED_OUT"
        case expired = "EXPIRED"
    }

    var duration: TimeInterval? {
        guard let checkOutTime = checkOutTime else { return nil }
        return checkOutTime.timeIntervalSince(checkInTime)
    }

    var isActive: Bool {
        status == .active
    }

    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: checkInTime, relativeTo: Date())
    }
}

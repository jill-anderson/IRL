import Foundation

struct User: Codable, Identifiable {
    let id: String
    var email: String
    var username: String
    var displayName: String
    var bio: String?
    var profilePhotoKey: String?
    var profilePhotoUrl: String?
    var galleryPhotoUrls: [String]?
    var birthDate: Date
    var gender: Gender
    var interestedIn: Gender?
    var jobTitle: String?
    var religiousAffiliation: String?
    var locationPrivacy: LocationPrivacy
    var notificationPreferences: NotificationPreferences?
    var lastActiveAt: Date
    var createdAt: Date
    var updatedAt: Date

    enum Gender: String, Codable, CaseIterable {
        case male
        case female
        case nonBinary = "non_binary"
        case preferNotToSay = "prefer_not_to_say"
        case other

        var displayName: String {
            switch self {
            case .male: return "Male"
            case .female: return "Female"
            case .nonBinary: return "Non-Binary"
            case .preferNotToSay: return "Prefer not to say"
            case .other: return "Other"
            }
        }
    }

    enum LocationPrivacy: String, Codable {
        case public_ = "public"
        case publicLocation = "PUBLIC"
        case friendsOnly = "FRIENDS"
        case friends_only = "friends_only"
        case privateLocation = "PRIVATE"
        case hidden = "hidden"

        var displayName: String {
            switch self {
            case .public_, .publicLocation: return "Public"
            case .friendsOnly, .friends_only: return "Friends Only"
            case .privateLocation, .hidden: return "Private"
            }
        }

        var description: String {
            switch self {
            case .public_, .publicLocation: return "Everyone can see when you're checked in"
            case .friendsOnly, .friends_only: return "Only friends can see when you're checked in"
            case .privateLocation, .hidden: return "No one can see when you're checked in"
            }
        }
    }
}

struct NotificationPreferences: Codable {
    var checkInNotifications: Bool
    var messageNotifications: Bool
    var pushEnabled: Bool

    init(checkInNotifications: Bool = true,
         messageNotifications: Bool = true,
         pushEnabled: Bool = true) {
        self.checkInNotifications = checkInNotifications
        self.messageNotifications = messageNotifications
        self.pushEnabled = pushEnabled
    }
}

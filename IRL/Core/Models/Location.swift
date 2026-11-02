import Foundation
import CoreLocation

struct Location: Codable, Identifiable {
    let id: String
    var name: String
    var type: LocationType
    var address: String
    var coordinate: Coordinate
    var geofenceId: String
    var radius: Double
    var createdAt: Date
    var updatedAt: Date

    enum LocationType: String, Codable, CaseIterable {
        case bar = "BAR"
        case restaurant = "RESTAURANT"
        case cafe = "CAFE"
        case club = "CLUB"

        var displayName: String {
            switch self {
            case .bar: return "Bar"
            case .restaurant: return "Restaurant"
            case .cafe: return "Cafe"
            case .club: return "Club"
            }
        }

        var icon: String {
            switch self {
            case .bar: return "wineglass"
            case .restaurant: return "fork.knife"
            case .cafe: return "cup.and.saucer"
            case .club: return "music.note"
            }
        }
    }

    var clLocation: CLLocation {
        CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
    }

    func distance(from location: CLLocation) -> Double {
        return clLocation.distance(from: location)
    }
}

struct Coordinate: Codable {
    var latitude: Double
    var longitude: Double

    var clCoordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }

    init(coordinate: CLLocationCoordinate2D) {
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
    }
}

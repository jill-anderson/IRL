import Foundation
import CoreLocation
import Combine

/// Manages location tracking, geofencing, and background location updates
class LocationManager: NSObject, ObservableObject {

    // MARK: - Published Properties

    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var currentLocation: CLLocation?
    @Published var isMonitoringLocation: Bool = false
    @Published var error: Error?

    // MARK: - Private Properties

    private let locationManager = CLLocationManager()
    private var monitoredRegions: Set<String> = [] // locationId -> CLRegion mapping
    private var geofenceManager: GeofenceManager?

    // MARK: - Singleton

    static let shared = LocationManager()

    override private init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 50 // Update every 50 meters
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.showsBackgroundLocationIndicator = false
    }

    // MARK: - Public Methods

    /// Request location authorization from user
    /// First requests "When In Use", then "Always" for background monitoring
    func requestAuthorization() {
        let status = locationManager.authorizationStatus

        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse:
            locationManager.requestAlwaysAuthorization()
        default:
            break
        }
    }

    /// Start monitoring user's location
    /// Uses significant location changes for battery efficiency
    func startMonitoring() {
        guard authorizationStatus == .authorizedAlways ||
              authorizationStatus == .authorizedWhenInUse else {
            print("Location authorization not granted")
            return
        }

        // Start significant location change monitoring (battery efficient)
        locationManager.startMonitoringSignificantLocationChanges()

        // Also start standard location updates for foreground accuracy
        locationManager.startUpdatingLocation()

        isMonitoringLocation = true
        print("Started monitoring location")
    }

    /// Stop monitoring user's location
    func stopMonitoring() {
        locationManager.stopMonitoringSignificantLocationChanges()
        locationManager.stopUpdatingLocation()
        isMonitoringLocation = false
        print("Stopped monitoring location")
    }

    /// Start monitoring geofences for nearby locations
    /// - Parameter locations: Array of locations to monitor
    func startMonitoringGeofences(_ locations: [Location]) {
        // iOS limit: 20 geofences per app
        let maxGeofences = 20

        // Stop monitoring all current geofences
        stopMonitoringAllGeofences()

        // Sort locations by distance from current location
        guard let currentLocation = currentLocation else {
            print("No current location available")
            return
        }

        let sortedLocations = locations.sorted { location1, location2 in
            let distance1 = location1.clLocation.distance(from: currentLocation)
            let distance2 = location2.clLocation.distance(from: currentLocation)
            return distance1 < distance2
        }

        // Monitor up to 20 closest locations
        let locationsToMonitor = Array(sortedLocations.prefix(maxGeofences))

        for location in locationsToMonitor {
            let region = CLCircularRegion(
                center: location.coordinate.clCoordinate,
                radius: location.radius,
                identifier: location.id
            )
            region.notifyOnEntry = true
            region.notifyOnExit = true

            locationManager.startMonitoring(for: region)
            monitoredRegions.insert(location.id)
            print("Started monitoring geofence: \(location.name)")
        }
    }

    /// Stop monitoring all geofences
    func stopMonitoringAllGeofences() {
        for region in locationManager.monitoredRegions {
            locationManager.stopMonitoring(for: region)
        }
        monitoredRegions.removeAll()
        print("Stopped monitoring all geofences")
    }

    /// Update geofences based on new location
    /// Called when user moves significantly
    func updateGeofences() async {
        guard let currentLocation = currentLocation else { return }

        // TODO: Fetch nearby locations from backend
        // let nearbyLocations = try await fetchNearbyLocations(
        //     latitude: currentLocation.coordinate.latitude,
        //     longitude: currentLocation.coordinate.longitude,
        //     radius: 5000 // 5km
        // )
        // startMonitoringGeofences(nearbyLocations)
    }

    /// Get distance to a location
    /// - Parameter location: Target location
    /// - Returns: Distance in meters, or nil if current location unavailable
    func distance(to location: Location) -> Double? {
        guard let currentLocation = currentLocation else { return nil }
        return location.clLocation.distance(from: currentLocation)
    }

    /// Format distance for display
    /// - Parameter meters: Distance in meters
    /// - Returns: Formatted string (e.g., "0.5 mi" or "500 m")
    func formatDistance(_ meters: Double) -> String {
        let miles = meters / 1609.34

        if miles < 0.1 {
            return String(format: "%.0f m", meters)
        } else if miles < 10 {
            return String(format: "%.1f mi", miles)
        } else {
            return String(format: "%.0f mi", miles)
        }
    }

    // MARK: - Private Methods

    /// Update device position with AWS Location Service
    private func updateDevicePosition(_ location: CLLocation) {
        // TODO: Update position with AWS Location Tracker
        // This enables server-side geofencing via Amazon Location Service
    }

    /// Handle significant location change
    private func handleSignificantLocationChange(_ location: CLLocation) {
        currentLocation = location

        // Update device position for AWS Location Service
        updateDevicePosition(location)

        // Update monitored geofences if user moved >2km
        Task {
            await updateGeofences()
        }
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationManager: CLLocationManagerDelegate {

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus

        if authorizationStatus == .authorizedAlways ||
           authorizationStatus == .authorizedWhenInUse {
            startMonitoring()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        currentLocation = location

        // Update position with AWS Location Service
        updateDevicePosition(location)
    }

    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("Entered geofence: \(region.identifier)")

        // TODO: Trigger auto check-in
        // Get locationId from region.identifier
        // Call CheckInService.autoCheckIn(locationId: region.identifier)

        // Notify user with local notification
        sendLocalNotification(
            title: "Welcome!",
            body: "You've been checked in automatically"
        )
    }

    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("Exited geofence: \(region.identifier)")

        // TODO: Trigger auto check-out
        // Call CheckInService.checkOut()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager error: \(error.localizedDescription)")
        self.error = error
    }

    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("Monitoring failed for region: \(region?.identifier ?? "unknown") - \(error.localizedDescription)")
    }

    // MARK: - Notifications

    private func sendLocalNotification(title: String, body: String) {
        // TODO: Implement local notification
        // Requires UNUserNotificationCenter setup
    }
}

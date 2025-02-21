//
//  LocationManager.swift
//  DoItOrLoseIt
//
//  Created by Jason Pien on 2/1/25.
//

import SwiftUI
import MapKit
import CoreLocation

/**
 * LocationManager is responsible for handling all location-related functionality in the application.
 * It manages user location updates, authorization status, and provides geographic calculations.
 *
 * The class implements CLLocationManagerDelegate to receive location updates and authorization changes.
 * It uses the Observable Object pattern to publish changes to the SwiftUI view hierarchy.
 *
 * Key Features:
 * - Handles location services availability checking
 * - Manages location authorization status
 * - Provides real-time user location updates
 * - Calculates geographic boundaries for geofencing
 */

final class LocationManager: NSObject, ObservableObject {
    
    @Published var alertItem: AlertItem?
    @Published var userLocation: CoordinateWrapper?
    @Published var isLocationReady = false
    
    private var deviceLocationManager: CLLocationManager?
    private var monitoredRegions: Set<CLCircularRegion> = []
    private weak var dataManager: DataManager?
    
    init(dataManager: DataManager) {
        self.dataManager = dataManager
        super.init()
        print("🚀 LocationManager initialized")
        checkIfLocationServicesIsEnable()
    }

    /**
     * Verifies if location services are enabled on the device and sets up the location manager.
     *
     * This method performs the following:
     * 1. Checks if system location services are enabled
     * 2. Initializes the device location manager if services are available
     * 3. Sets up the delegate and accuracy settings
     * 4. Triggers a location authorization check
     *
     * The operation is performed on a background thread to avoid blocking the main thread,
     * with UI updates being dispatched back to the main thread.
     */
    func checkIfLocationServicesIsEnable() {
        DispatchQueue.global(qos: .userInitiated).async {
            let isLocationEnabled = CLLocationManager.locationServicesEnabled()
            DispatchQueue.main.async {
                if isLocationEnabled {
                    self.deviceLocationManager = CLLocationManager()
                    self.deviceLocationManager!.delegate = self
                    self.deviceLocationManager?.desiredAccuracy = kCLLocationAccuracyBest
                    self.checkLocationAuth()
                } else {
                    self.alertItem = AlertContext.locationDisabled
                }
            }
        }
    }
    
    /*
     Takes an array of PinTasks and sets up geofencing regions for each one.
     When a user crosses one of these fences, iOS will notify the app.
     The first part clears any existing monitored regions to avoid duplicates,
     then creates a new 50-meter radius circular region for each PinTask.
     */
    func startMonitoringPinTasks(_ pinTasks: [PinTask]) {
        guard let deviceLocationManager = deviceLocationManager else { return }
        
        for region in deviceLocationManager.monitoredRegions {
            deviceLocationManager.stopMonitoring(for: region)
        }
        
        for pinTask in pinTasks {
            let center = CLLocationCoordinate2D(latitude: pinTask.latitude, longitude: pinTask.longitude)
            guard let id = pinTask.id?.uuidString else { continue }
            
            let region = CLCircularRegion(center: center, radius: 50, identifier: id)
            region.notifyOnEntry = true
            region.notifyOnExit = false
            
            if CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
                deviceLocationManager.startMonitoring(for: region)
                monitoredRegions.insert(region)
            }
        }
    }
        
    /**
     * CLLocationManagerDelegate method that handles incoming location updates.
     *
     * When new location data is received:
     * 1. Extracts the most recent location from the provided array
     * 2. Updates the published userLocation property
     * 3. Sets isLocationReady to true to indicate active location services
     *
     * Parameters:
     * - manager: The location manager providing the update
     * - locations: Array of location objects, typically containing historical and current locations
     */
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        print("📍 Location update received: \(location.coordinate)")
        userLocation = CoordinateWrapper(coordinate: location.coordinate)
        isLocationReady = true
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        guard let circularRegion = region as? CLCircularRegion,
            let dataManager = dataManager else { return }
    
        DispatchQueue.main.async {
            dataManager.deletePinTask(withId: UUID(uuidString: region.identifier))
        }

        // Stop monitoring this region since the task is complete
        manager.stopMonitoring(for: region)
        monitoredRegions.remove(circularRegion)
    }

    /**
    * Verifies and handles the current location authorization status.
    *
    * This private method:
    * 1. Checks the current authorization status
    * 2. Handles each possible authorization state appropriately
    * 3. Requests authorization if needed
    * 4. Sets appropriate alert items for restricted or denied states
    * 5. Begins location updates when authorized
    */
    private func checkLocationAuth() {
        guard let deviceLocationManager = deviceLocationManager else {
            print("❌ Device location manager is nil")
            return
        }
        
        print("📱 Checking location auth status: \(deviceLocationManager.authorizationStatus.rawValue)")
        
        switch deviceLocationManager.authorizationStatus {
        case .notDetermined:
            print("📍 Requesting authorization")
            deviceLocationManager.requestAlwaysAuthorization()
        case .restricted:
            print("❌ Location restricted")
            alertItem = AlertContext.locationRestricted
        case .denied:
            print("❌ Location denied")
            alertItem = AlertContext.locationDenied
        case .authorizedAlways, .authorizedWhenInUse:
            print("✅ Location authorized")
            deviceLocationManager.startUpdatingLocation()
            deviceLocationManager.allowsBackgroundLocationUpdates = true
            deviceLocationManager.pausesLocationUpdatesAutomatically = false
        @unknown default:
            print("❓ Unknown authorization status")
            break
        }
    }
}

extension LocationManager: CLLocationManagerDelegate {
    /**
     * Delegate method called when location authorization status changes.
     *
     * Triggers a recheck of location authorization when the status changes,
     * ensuring the app responds appropriately to user permission changes.
     */
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuth()
    }
    /**
     * Calculates a bounding box around the user's current location.
     *
     * Uses the Haversine formula to calculate a square boundary around the user's location.
     * The calculation takes into account the Earth's curvature and provides coordinates
     * for the southwest and northeast corners of the bounding box.
     *
     * The bounding box has the following properties:
     * - Centered on the user's current location
     * - Radius: 50 meters from the center point
     * - Accounts for Earth's curvature in the calculation
     *
     * Returns: A tuple containing the southwest and northeast coordinates of the bounding box,
     *          or nil if the user's location is not available
     */
    func calculateBoundingBox() -> (southWest: CLLocationCoordinate2D, northEast: CLLocationCoordinate2D)? {
        // Haversine Formula
        guard let userlocation = userLocation?.coordinate else { return nil }
        let radiusInMeters: CLLocationDistance = 50
        let earthRadiusInMeters: CLLocationDistance = 6378137.0
        
        let latitude = userlocation.latitude * .pi / 180
        let longitude = userlocation.longitude * .pi / 180
        let angularDistance = radiusInMeters / earthRadiusInMeters
        let SouthWestLatitude = latitude - angularDistance
        let SouthWestLongitude = longitude - angularDistance / cos(latitude)
        let NorthEastLatitude = latitude + angularDistance
        let NorthEastLongitude = longitude + angularDistance / cos(latitude)
        
        // Convert to degrees
        let southWest = CLLocationCoordinate2D(
            latitude: SouthWestLatitude * 180.0 / .pi,
            longitude: SouthWestLongitude * 180.0 / .pi
        )
        let northEast = CLLocationCoordinate2D(
            latitude: NorthEastLatitude * 180.0 / .pi,
            longitude: NorthEastLongitude * 180.0 / .pi
        )
        
        return (southWest, northEast)
    }
}

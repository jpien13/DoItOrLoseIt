//
//  LocationManager.swift
//  DoItOrLoseIt
//
//  Created by Jason Pien on 2/1/25.
//

import SwiftUI
import MapKit

/*
LocationManager

Data Flow:
1. App Entry (DoItOrLoseItApp.swift):
   - Creates single LocationManager instance
   - Injects into environment: .environmentObject(locationManager)

2. MapView Usage (MapView.swift):
   - Receives manager via @EnvironmentObject
   - Calls checkIfLocationServicesIsEnable() on .onAppear
   - Observes location changes through .onChange of userLocation coordinates
   - Updates map region when coordinates change
   - Displays alerts through @Published alertItem

3. Location Updates (LocationManager.swift):
   - checkIfLocationServicesIsEnable() -> sets up CLLocationManager
   - CLLocationManagerDelegate callbacks:
     → locationManagerDidChangeAuthorization -> checkLocationAuth()
     → locationManager(didUpdateLocations) -> updates @Published userLocation

 CLLocationManager (the delegator) needs to tell something when the location changes
 LocationManager (the delegate) says "I'll handle those notifications"
 When we set delegate = self, we're telling CLLocationManager: "Send all location updates to me"
 When location changes happen, CLLocationManager automatically calls methods on our LocationManager through the delegate relationship
*/

final class LocationManager: NSObject, ObservableObject {
    
    @Published var alertItem: AlertItem?
    @Published var userLocation: CLLocationCoordinate2D?
    @Published var isLocationReady = false
    
    // 1. Declare conformance to the delegate protocol
    private var deviceLocationManager: CLLocationManager?

    
    // 3. 3. Set up the delegate relationship
    func checkIfLocationServicesIsEnable() {
        if CLLocationManager.locationServicesEnabled() {
            deviceLocationManager = CLLocationManager()
            deviceLocationManager!.delegate = self
            deviceLocationManager?.desiredAccuracy = kCLLocationAccuracyBest
        } else {
            alertItem = AlertContext.locationDisabled
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        userLocation = location.coordinate
        isLocationReady = true
    }

    
    private func checkLocationAuth() {
        
        guard let deviceLocationManager = deviceLocationManager else {return}
        
        switch deviceLocationManager.authorizationStatus {
        case .notDetermined:
            deviceLocationManager.requestWhenInUseAuthorization()
        case .restricted:
            alertItem = AlertContext.locationRestricted
        case .denied:
            alertItem = AlertContext.locationDenied
        case .authorizedAlways, .authorizedWhenInUse:
            deviceLocationManager.startUpdatingLocation()
        @unknown default:
            break
            
        }
    }
}

// 2. Implement the delegate protocol
// functions in extension contains additional utility functions that are related to location calculations but are not part of the core functionality
extension LocationManager: CLLocationManagerDelegate {
    // gets called as soon as CLLocationManager is created (line XX)
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuth()
    }
    
    func calculateBoundingBox() -> (southwest: CLLocationCoordinate2D, northEast: CLLocationCoordinate2D)? {
        let pi = 3.14159
        // Haversine Formula
        guard let userlocation = userLocation else { return nil }
        let radiusInMeters: CLLocationDistance = 50
        let earthRadiusInMeters: CLLocationDistance = 6378137.0
        
        let latitude = userlocation.latitude * pi / 180
        let longitude = userlocation.longitude * pi / 180
        let angularDistance = radiusInMeters / earthRadiusInMeters
        let SouthWestLatitude = latitude - angularDistance
        let SouthWestLongitude = longitude - angularDistance / cos(latitude)
        let NorthEastLatitude = latitude + angularDistance
        let NorthEastLongitude = longitude + angularDistance / cos(latitude)
        
        // Convert to degrees
        let southWest = CLLocationCoordinate2D(
            latitude: SouthWestLatitude * 180.0 / pi,
            longitude: SouthWestLongitude * 180.0 / pi
        )
        let northEast = CLLocationCoordinate2D(
            latitude: NorthEastLatitude * 180.0 / pi,
            longitude: NorthEastLongitude * 180.0 / pi
        )
        
        return (southWest, northEast)
    }
}

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
extension LocationManager: CLLocationManagerDelegate {
    // gets called as soon as CLLocationManager is created (line XX)
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuth()
    }
}

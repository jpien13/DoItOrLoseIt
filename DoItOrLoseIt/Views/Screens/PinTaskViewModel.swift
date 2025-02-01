//
//  PinTaskViewModel.swift
//  DoItOrLoseIt
//
//  Created by Jason Pien on 1/28/25.
//

import SwiftUI
import MapKit

// =============================================================
// A VIEWMODEL that bridges the VIEW and MODEL, providing methods
// to manipulate and fetch the data. In this case, it manages
// the list of PinTask items and makes them available to VIEWS
//
// (VM in MVVM Model-View-ViewModel)
// =============================================================

class PinTaskViewModel: ObservableObject {
    
    @Published var alertItem: AlertItem?
    @Published var pinTasks: [PinTask] = MockData.pinTasks // @Published to notify Views of data changes

    var deviceLocationManager: CLLocationManager? // optional bc only make this is location services is enabled
    
    func checkIfLocationServicesIsEnabled() {
        if CLLocationManager.locationServicesEnabled() {
            deviceLocationManager = CLLocationManager()
            deviceLocationManager?.desiredAccuracy = kCLLocationAccuracyBest
        } else {
            alertItem = AlertContext.locationDisabled
        }
    }
    
    func checkLocationAuth() {
        guard let deviceLocationManager = deviceLocationManager else {return}
        
        switch deviceLocationManager.authorizationStatus {
        case .notDetermined:
            deviceLocationManager.requestWhenInUseAuthorization()
        case .restricted:
            alertItem = AlertContext.locationRestricted
        case .denied:
            alertItem = AlertContext.locationDenied
        case .authorizedAlways, .authorizedWhenInUse:
            break
        @unknown default:
            break
            
        }
    }
    
    // TODO: methods to add and remove tasks
}

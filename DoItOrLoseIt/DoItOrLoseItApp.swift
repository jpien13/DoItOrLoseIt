//
//  DoItOrLoseItApp.swift
//  DoItOrLoseIt
//
//  Created by Jason Pien on 1/23/25.
//

import SwiftUI
import SwiftData

@main
struct DoItOrLoseItApp: App {
    
    let locationManager = LocationManager()
    
    var body: some Scene {
        WindowGroup {
            HomeTabView()
                .environmentObject(locationManager)
        }
    }
}


// TODO: LocationManager: To handle all location-related logi. Use CLLocationManager to get the user's location and update the map's region
// TODO: DataManager: To save PinTask items locally (UserDefaults or CoreData), need to create a DataManager to handle persistence. A class that saves and loads PinTask items from UserDefaults.

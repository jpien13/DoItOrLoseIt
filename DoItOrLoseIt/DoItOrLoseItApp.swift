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


// TODO: DataManager: To save PinTask items locally (UserDefaults or CoreData), need to create a DataManager to handle persistence. A class that saves and loads PinTask items from UserDefaults.
// TODO: Watch add to recover lost wager. Lost wagers go to charity. Ad revenue goes to me.

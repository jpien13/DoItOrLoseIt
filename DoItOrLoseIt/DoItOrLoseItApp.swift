//
//  DoItOrLoseItApp.swift
//  DoItOrLoseIt
//
//  Created by Jason Pien on 1/23/25.
//

import SwiftUI
import SwiftData
import BackgroundTasks

@main
struct DoItOrLoseItApp: App {
    @StateObject private var dataManager = DataManager.shared
    @StateObject private var locationManager: LocationManager
    
    init() {
        let locationManager = LocationManager(dataManager: DataManager.shared)
        _locationManager = StateObject(wrappedValue: locationManager)
    }
    
    var body: some Scene {
        WindowGroup {
            HomeTabView()
                .environmentObject(locationManager)
                .environmentObject(dataManager)
                .environment(\.managedObjectContext, dataManager.container.viewContext)
        }
    }
}

// TODO: Add wager subtract and balance
// TODO: Watch ad to recover lost wager. Lost wagers go to charity. Ad revenue goes to me.
// TODO: Maybe make it like flora or finch with virtual world
// TODO: Before pushing to a Testflight, add button for user to send dev the logs so I can debug any issues found.
/*
Honor my price is probably best (if you complete you get extra rewards)
Keep virtual plant or character for people who wanna do it for free?
Build momentum and have friend leaderboard or accountibility group?
 */

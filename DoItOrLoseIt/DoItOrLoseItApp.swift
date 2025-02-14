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
    // MARK: Core data
    @StateObject private var dataManager: DataManager = DataManager()
    @StateObject private var locationManager = LocationManager()
    
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
// TODO: Honor my price button
// TODO: Watch ad to recover lost wager. Lost wagers go to charity. Ad revenue goes to me.
/*
 Users deposit money upfront (e.g., $20 into their "Gym Commitment Fund").
 Each time they successfully check in at the gym, they unlock a portion of their deposit (e.g., $5 per gym visit).
 If they fail to check in, they don’t instantly lose money—instead, they might need extra gym visits to fully unlock their deposit.
 If they fail too often, remaining funds could be:
 Donated to a fitness-related charity (keeps it ethical & App Store-friendly).
 Converted to app credits for a retry (keeps users engaged).
 Rolled over for a new challenge instead of being lost outright.
 */



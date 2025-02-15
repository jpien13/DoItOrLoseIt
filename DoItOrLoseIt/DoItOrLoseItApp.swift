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


// TODO: Deadlines
// TODO: Keep track of failed tasks and when next open app, show honor price button
// TODO: Add wager subtract and balance
// TODO: Honor my price button
// TODO: Watch ad to recover lost wager. Lost wagers go to charity. Ad revenue goes to me.


/*
Honor my price is probably best (if you complete you get extra rewards)
Keep virtual plant or character for people who wanna do it for free?
Build momentum and have friend leaderboard or accountibility group?
 */

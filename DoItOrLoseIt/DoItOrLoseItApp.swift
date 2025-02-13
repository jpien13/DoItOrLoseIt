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


// TODO: Add deadline
// TODO: Add wager subtract and balance
// TODO: Watch ad to recover lost wager. Lost wagers go to charity. Ad revenue goes to me.


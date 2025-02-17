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
    @StateObject private var dataManager: DataManager = DataManager()
    @StateObject private var locationManager = LocationManager()
    private let backgroundTaskManager: BackgroundTaskManager
    
    init() {
        let dataManager = DataManager()
        backgroundTaskManager = BackgroundTaskManager(dataManager: dataManager)
        _dataManager = StateObject(wrappedValue: dataManager)

        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge]
        ) { granted, error in
            if granted {
                print("Notifications Permission Granted")
            } else if let error = error {
                print("Notifications Permission Denied: \(error)")
            }
        }
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
// TODO: Fix bug where if you add task ontop of yourself and the time is now, then you fail. (can only set deadline more than 1 minutes ahead)
// TODO: Honor my price button
// TODO: Watch ad to recover lost wager. Lost wagers go to charity. Ad revenue goes to me.
// TODO: Fix the bigs seen in console when entering task title
// TODO: Push notifications using a server using firebase

/*
Honor my price is probably best (if you complete you get extra rewards)
Keep virtual plant or character for people who wanna do it for free?
Build momentum and have friend leaderboard or accountibility group?
 */

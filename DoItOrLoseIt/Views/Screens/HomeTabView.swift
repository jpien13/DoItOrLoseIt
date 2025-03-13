//
//  ContentView.swift
//  DoItOrLoseIt
//
//  Created by Jason Pien on 1/23/25.
//

import SwiftUI
import SwiftData
import OSLog

struct HomeTabView: View {

    @EnvironmentObject private var locationManager: LocationManager
    @EnvironmentObject private var dataManager: DataManager
    @State private var showingFailedTaskAlert = false
    @State private var failedTasks: [PinTask] = []
    
    var body: some View {
        TabView {
            BalanceView()
                .tabItem {
                    Image(systemName: "dollarsign.circle")
                    Text("Balance")
                }
            TaskListView()
                .environment(\.managedObjectContext, dataManager.container.viewContext)
                .tabItem {
                    Image(systemName: "checklist")
                    Text("Tasks")
                }
            MapView()
                .environment(\.managedObjectContext, dataManager.container.viewContext)
                .tabItem {
                    Image(systemName: "map")
                    Text("Map")
                }
                .ignoresSafeArea(edges: .top)
                .padding(.bottom)
            
        }
        .onAppear {
            dataManager.checkForFailedDeadlines()
            dataManager.setupAppStateObservers()
            NotificationCenter.default.addObserver(
                forName: .taskFailedNotification,
                object: nil,
                queue: .main
            ) { notification in
                if let tasks = notification.userInfo?["failedTasks"] as? [PinTask] {
                    os_log("Found %d failed tasks", log: . app, type: .info, tasks.count)
                    failedTasks = tasks
                    showingFailedTaskAlert = !tasks.isEmpty
                }
            }
        }
        .sheet(isPresented: $showingFailedTaskAlert) {
            FailTaskView(
                failedTasks: $failedTasks,
                isPresented: $showingFailedTaskAlert
            )
        }
    }
}

#Preview {
    let dataManager = DataManager()
    HomeTabView()
        .environmentObject(LocationManager(dataManager: dataManager))
        .environmentObject(DataManager())
        .environment(\.managedObjectContext, dataManager.container.viewContext)
}

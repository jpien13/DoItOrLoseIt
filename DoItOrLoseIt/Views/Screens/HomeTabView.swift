//
//  ContentView.swift
//  DoItOrLoseIt
//
//  Created by Jason Pien on 1/23/25.
//

import SwiftUI
import SwiftData

struct HomeTabView: View {

    @EnvironmentObject private var locationManager: LocationManager
    @EnvironmentObject private var dataManager: DataManager
    
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
    }
}

#Preview {
    let dataManager = DataManager()
    HomeTabView()
        .environmentObject(LocationManager())
        .environmentObject(DataManager())
        .environment(\.managedObjectContext, dataManager.container.viewContext)
}

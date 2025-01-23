//
//  ContentView.swift
//  DoItOrLoseIt
//
//  Created by Jason Pien on 1/23/25.
//

import SwiftUI
import SwiftData

struct HomeTabView: View {
    var body: some View {
        TabView {
            BalanceView()
                .tabItem {
                    Image(systemName: "dollarsign.circle")
                    Text("Balance")
                }
            TaskView()
                .tabItem {
                    Image(systemName: "checklist")
                    Text("Tasks")
                }
            MapView()
                .tabItem {
                    Image(systemName: "map")
                    Text("Map")
                }
        }
    }
}

#Preview {
    HomeTabView()
        .modelContainer(for: Item.self, inMemory: true)
}

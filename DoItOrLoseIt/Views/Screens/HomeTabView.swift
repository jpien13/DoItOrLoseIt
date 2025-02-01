//
//  ContentView.swift
//  DoItOrLoseIt
//
//  Created by Jason Pien on 1/23/25.
//

import SwiftUI
import SwiftData

struct HomeTabView: View {

    @StateObject private var viewModel = PinTaskViewModel() // creates the 1 instance that acts as source of truth and persists for the lifetime of HomeTabView
    
    var body: some View {
        TabView {
            BalanceView()
                .tabItem {
                    Image(systemName: "dollarsign.circle")
                    Text("Balance")
                }
            TaskListView()
                .environmentObject(viewModel) // inject ViewModel into this view so this view has 1 shared source of truth
                .tabItem {
                    Image(systemName: "checklist")
                    Text("Tasks")
                }
            MapView()
                .environmentObject(viewModel) // inject ViewModel into this view so this view has 1 shared source of truth
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
    HomeTabView()
        .environmentObject(PinTaskViewModel())
}

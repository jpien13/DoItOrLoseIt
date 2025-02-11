//
//  TaskView.swift
//  DoItOrLoseIt
//
//  Created by Jason Pien on 1/23/25.
//

import SwiftUI

// =============================================================
// A VIEW that renders the UI displaying data from the VIEWMODEL
// (V in MVVM Model-View-ViewModel)
// =============================================================

struct TaskListView: View {
    
    @EnvironmentObject var viewModel: PinTaskViewModel
    @EnvironmentObject var manager: DataManager
    @Environment(\.managedObjectContext) var viewContext
    
    var body: some View {
        
        NavigationView(){
            ScrollView {
                VStack{
                    Spacer()
                        .frame(height: 20)
                    
                    ForEach(viewModel.pinTasks, id: \.id) { pinTaskItem in
                        NavigationLink(value: pinTaskItem) {
                            TaskItemView(pinTask: pinTaskItem)
                        }
                    }
                    
                    Spacer()
                }
                .navigationTitle("Your Tasks")
            }
        }
    }
    
}

#Preview {
    TaskListView()
        .environmentObject(PinTaskViewModel())
}

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
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \PinTask.deadline, ascending: true)])
    private var pinTasks: FetchedResults<PinTask>
    
    var body: some View {
        
        NavigationView(){
            ScrollView {
                VStack{
                    Spacer()
                        .frame(height: 20)
                    
                    ForEach(pinTasks, id: \.self) { pinTask in
                        NavigationLink(value: pinTask) {
                            TaskItemView(pinTask: pinTask)
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

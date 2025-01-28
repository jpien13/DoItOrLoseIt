//
//  TaskView.swift
//  DoItOrLoseIt
//
//  Created by Jason Pien on 1/23/25.
//

import SwiftUI

struct TaskListView: View {
    
    var body: some View {
        
        NavigationView(){
            ScrollView {
                VStack{
                    Spacer()
                        .frame(height: 20)
                    
                    ForEach(MockData.pinTasks, id: \.id) { pinTaskItem in
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
}

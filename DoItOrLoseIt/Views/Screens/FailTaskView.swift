//
//  FailTaskView.swift
//  DoItOrLoseIt
//
//  Created by Jason Pien on 2/15/25.
//

import SwiftUI

struct FailTaskView: View {
    
    @Environment(\.managedObjectContext) var viewContext
    @Binding var failedTasks: [PinTask]
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView {
            List(failedTasks, id: \.id) { task in
                VStack(alignment: .leading) {
                    Text(task.title ?? "Untitled Task")
                        .font(.headline)
                    Text("Deadline: \(task.deadline?.formatted() ?? "No deadline")")
                        .font(.subheadline)
                    Text("Wager: $\(task.challengeAmount, specifier: "%.2f")")
                        .font(.subheadline)
                    
                    HStack {
                        Button("Honor My Price") {
                            handleHonorPrice(task)
                        }
                        .buttonStyle(.borderedProminent)
                        
                        Button("False Failure") {
                            handleFalseFailure(task)
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding(.top, 8)
                }
                .padding(.vertical, 8)
            }
            .navigationTitle("Failed Tasks")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        isPresented = false
                    }
                }
            }
        }
    }
    
    private func handleHonorPrice(_ task: PinTask) {
        failedTasks.removeAll { $0.id == task.id }
        viewContext.delete(task)
        do {
            try viewContext.save()
            if failedTasks.isEmpty {
                isPresented = false
            }
        } catch {
            print("Error honorring price: \(error.localizedDescription)")
        }
    }
    
    private func handleFalseFailure(_ task: PinTask) {
        // TODO: Implement false failure logic
        task.taskStatus = .active
        try? viewContext.save()
    }
}

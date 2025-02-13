//
//  TaskItemView.swift
//  DoItOrLoseIt
//
//  Created by Jason Pien on 1/25/25.
//

import SwiftUI

struct TaskItemView: View {
    @Environment(\.managedObjectContext) var viewContext
    @EnvironmentObject var dataManager: DataManager
    
    let pinTask: PinTask
    
    var body: some View {
       
        VStack {
            HStack{
                Text("📍" + String(pinTask.title ?? "My Task"))
                    .fontWeight(.bold)
                Spacer()
            }
            .padding(.horizontal)
            HStack{
                (Text(String(pinTask.latitude)) + Text(", ") + Text(String(pinTask.longitude)))
                Spacer()
                Text("$ ") + Text(String(format: "%.2f", pinTask.wager))
            }
            .padding(.horizontal)
            HStack {
                if let deadline = pinTask.deadline {
                    Text(formatDate(deadline))
                }
                Spacer()
            }
            .padding(.horizontal)
            
            
        }
        .frame(width: 350, height: 90)
        .foregroundColor(Color.black)
        .background(Color.white)
        .cornerRadius(10)
        .padding(.horizontal)
        .shadow(radius: 3)
    
    }
    
    private func formatDate(_ date: Date) -> String {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            return formatter.string(from: date)
        }
}

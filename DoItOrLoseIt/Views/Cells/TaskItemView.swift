//
//  TaskItemView.swift
//  DoItOrLoseIt
//
//  Created by Jason Pien on 1/25/25.
//

import SwiftUI

struct TaskItemView: View {
    
    var pinTask: PinTaskDummy
    @EnvironmentObject var viewModel: PinTaskViewModel
    
    var body: some View {
       
        VStack {
            HStack{
                (Text("📍" + String(pinTask.latitude)) + Text(", ") + Text(String(pinTask.longitude)))
                    .fontWeight(.bold)
                Spacer()
                Text("$ ") + Text(String(format: "%.2f", pinTask.wager))
            }
            .padding(.horizontal)
            HStack {
                Text(String(pinTask.deadline))
                Spacer()
            }
            .padding(.horizontal)
            
            
        }
        .frame(width: 350, height: 60)
        .foregroundColor(Color.black)
        .background(Color.white)
        .cornerRadius(10)
        .padding(.horizontal)
        .shadow(radius: 3)
    
    }
}

#Preview {
    TaskItemView(pinTask: MockData.samplePinTask)
}

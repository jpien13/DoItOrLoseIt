//
//  PinTaskInputForm.swift
//  DoItOrLoseIt
//
//  Created by Jason Pien on 2/11/25.
//

import SwiftUI
import MapKit

struct PinTaskInputForm: View {
    
    @Environment(\.dismiss) private var dismiss
    // MARK: Core data variables
    @EnvironmentObject var manager: DataManager
    @Environment(\.managedObjectContext) var viewContext
    
    let coordinate: CLLocationCoordinate2D
    var onSave: (CLLocationCoordinate2D) -> Void
    
    @State private var wager: Double = 0.0
    @State private var deadline: Date = Date()
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    Text("Latitude: \(coordinate.latitude)")
                    Text("Longitude: \(coordinate.longitude)")
                }
                Section(header: Text("Task Details")) {
                    HStack {
                        Text("$")
                        TextField("Wager Amount", value: $wager, format: .number)
                            .keyboardType(.decimalPad)
                    }
                    
                    DatePicker("Deadline", selection: $deadline, displayedComponents: [.date, .hourAndMinute])
                }
                
            }
            .navigationTitle("Add New Pin")
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                },
                trailing: Button("Save") {
                    savePinTask()
                    dismiss()
                }
            )
        }
    }
    
    func savePinTask() {
        let pinTask = PinTask(context: self.viewContext)
        pinTask.id = UUID()
        pinTask.latitude = self.coordinate.latitude
        pinTask.longitude = self.coordinate.longitude
        pinTask.wager = self.wager
        pinTask.deadline = self.deadline
        
        do {
            try self.viewContext.save()
            print("PinTask Saved Successfully")
        } catch {
            print("Whoops \\(error.localizedDescription)")
        }
            
    }
}

#Preview {
    let mockCoordinate = CLLocationCoordinate2D(
        latitude: 41.826084,
        longitude: -71.403246
    )
    
    return PinTaskInputForm(
        coordinate: mockCoordinate,
        onSave: { _ in
            print("Save tapped in preview")
        }
    )
}

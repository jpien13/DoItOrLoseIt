//
//  PinTaskInputForm.swift
//  DoItOrLoseIt
//
//  Created by Jason Pien on 2/11/25.
//

import SwiftUI
import MapKit
import CoreData
import OSLog

struct PinTaskInputForm: View {
    
    @Environment(\.dismiss) private var dismiss
    // MARK: Core data variables
    @EnvironmentObject var manager: DataManager
    @Environment(\.managedObjectContext) var viewContext
    
    let coordinate: CLLocationCoordinate2D
    var onSave: (CLLocationCoordinate2D) -> Void
    
    @State private var challengeAmount: Double = 0.0
    @State private var deadline: Date = Date()
    @State private var title: String = "My Task"
    @State private var showInvalidDateAlert: Bool = false
    
    private var minimumDate: Date {
        Date().addingTimeInterval(120)
    }
    
    private func isValidDeadline() -> Bool {
        return deadline >= minimumDate
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    Text("Latitude: \(coordinate.latitude)")
                    Text("Longitude: \(coordinate.longitude)")
                }
                Section(header: Text("Task Details")) {
                    TextField("Task Name", text: $title)
                    HStack {
                        Text("$")
                        TextField("challengeAmount Amount", value: $challengeAmount, format: .number)
                            .keyboardType(.decimalPad)
                    }
                    
                    DatePicker("Deadline",
                               selection: $deadline,
                               in: minimumDate...,
                               displayedComponents: [.date, .hourAndMinute])
                }
                
            }
            .navigationTitle("Add New Pin")
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                },
                trailing: Button("Save") {
                    if isValidDeadline() {
                        savePinTask()
                        dismiss()
                    } else {
                        showInvalidDateAlert = true
                    }
                    
                }
            )
            .alert("Invalid Deadline",
                   isPresented: $showInvalidDateAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Please set a deadline that is at least a few minutes in the future.")
            }
        }
    }
    
    func savePinTask() {
        let pinTask = PinTask(context: self.viewContext)
        pinTask.id = UUID()
        pinTask.latitude = self.coordinate.latitude
        pinTask.longitude = self.coordinate.longitude
        pinTask.challengeAmount = self.challengeAmount
        pinTask.deadline = self.deadline
        pinTask.title = self.title
        pinTask.status = TaskStatus.active.rawValue
        
        os_log("📍 Saving new PinTask coordinates:", log: .app, type: .info)
        os_log("- Latitude: %f", log: .app, type: .info, self.coordinate.latitude)
        os_log("- Longitude: %f", log: .app, type: .info, self.coordinate.longitude)
        os_log("Saving new PinTask:", log: .app, type: .info)
        os_log("Title: %{public}@", log: .app, type: .info, self.title)
        os_log("Deadline: %{public}@", log: .app, type: .info, String(describing: self.deadline))
        os_log("Status: %{public}@", log: .app, type: .info, TaskStatus.active.rawValue)
        
        do {
            try self.viewContext.save()
            os_log("PinTask Saved Successfully", log: .data, type: .info)
            let fetchRequest: NSFetchRequest<PinTask> = PinTask.fetchRequest()
            let tasks = try self.viewContext.fetch(fetchRequest)
            os_log("Total tasks in Core Data: %d", log: .data, type: .info, tasks.count)
            os_log("All tasks:", log: .data, type: .info)
            for task in tasks {
                let titleString = task.title ?? "untitled"
                let deadlineString = task.deadline?.description ?? "no deadline"
                let statusString = String(describing: task.status)

                os_log("- Title: %{public}@, Deadline: %{public}@, Status: %{public}@",
                       log: .app,
                       type: .info,
                       titleString,
                       deadlineString,
                       statusString)
            }
        } catch {
            os_log("Error saving PinTask: %{public}@", log: .data, type: .error, error.localizedDescription)
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

//
//  DataManager.swift
//  DoItOrLoseIt
//
//  Created by Jason Pien on 2/11/25.
//
//  https://medium.com/@rizal_hilman/swiftui-tutorial-core-data-7df0cfddd965
//

import CoreData
import Foundation
import MapKit
import SwiftUI
// Main data manager to handle the PinTask items
class DataManager: NSObject, ObservableObject {
    
    /// Dynamic properties that the UI will react to
    @Published var todos: [PinTask] = [PinTask]()
    @Published var alertItem: AlertItem?
    
    // Add the Core Data container with the model name
    let container: NSPersistentContainer = NSPersistentContainer(name: "PinTaskList")
    
    // Default init method. Load the Core Data container
    override init() {
        super.init()
        container.loadPersistentStores { _, _ in }
    }
    
    func filterPinTasksInBoundingBox(
        boundingBox: (southWest: CLLocationCoordinate2D, northEast: CLLocationCoordinate2D),
        context: NSManagedObjectContext
    ) -> [PinTask] {
        let fetchRequest: NSFetchRequest<PinTask> = PinTask.fetchRequest()
        
        // Create a compound predicate for the bounding box
        let latitudePredicate = NSPredicate(
            format: "latitude >= %f AND latitude <= %f",
            boundingBox.southWest.latitude,
            boundingBox.northEast.latitude
        )
        
        let longitudePredicate = NSPredicate(
            format: "longitude >= %f AND longitude <= %f",
            boundingBox.southWest.longitude,
            boundingBox.northEast.longitude
        )
        
        fetchRequest.predicate = NSCompoundPredicate(
            andPredicateWithSubpredicates: [latitudePredicate, longitudePredicate]
        )
        
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Error fetching filtered pin tasks: \(error)")
            return []
        }
    }
    
    func removePinTasksWithin50Meters(
        userLocation: CLLocationCoordinate2D,
        boundingbox: (southWest: CLLocationCoordinate2D, northEast: CLLocationCoordinate2D),
        context: NSManagedObjectContext
    ) {
        let filteredTasks = filterPinTasksInBoundingBox(boundingBox: boundingbox, context: context)
        
        for pinTask in filteredTasks {
            let taskLocation = CLLocationCoordinate2D(
                latitude: pinTask.latitude,
                longitude: pinTask.longitude
            )
            
            let distance = LocationUtils.haversineDistance(
                from: userLocation,
                to: taskLocation
            )
            
            if distance <= 50 {
                context.delete(pinTask)
            }
        }
        
        // Save changes after all deletions
        do {
            try context.save()
        } catch {
            alertItem = AlertItem(
                title: Text("Error"),
                message: Text("Unable to delete completed tasks."),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}

extension DataManager {
    /*
     This function is called when a user enters a monitored region.
     It finds the corresponding PinTask in Core Data using its UUID and deletes it.
     */
    func deletePinTask(withId id: UUID?) {
        guard let id = id else { return }
        
        let fetchRequest: NSFetchRequest<PinTask> = PinTask.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            let results = try container.viewContext.fetch(fetchRequest)
            if let taskToDelete = results.first {
                container.viewContext.delete(taskToDelete)
                try container.viewContext.save()
            }
        } catch {
            alertItem = AlertItem(
                title: Text("Error"),
                message: Text("Unable to delete completed task."),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    func checkForFailedDeadlines() {
        let fetchRequest: NSFetchRequest<PinTask> = PinTask.fetchRequest()
        
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "deadline", ascending: true)
        ]
        
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            // First condition: task must be active
            NSPredicate(format: "status == %@", TaskStatus.active.rawValue),
            // Second condition: deadline must be in the past
            NSPredicate(format: "deadline < %@", Date() as NSDate)
        ])
        
        container.viewContext.performAndWait {
            do {
                let failedTasks = try container.viewContext.fetch(fetchRequest)
                guard !failedTasks.isEmpty else { return }
                var updatedTasks: [PinTask] = []
                for task in failedTasks {
                    task.taskStatus = .failed
                    updatedTasks.append(task)
                }
                if container.viewContext.hasChanges {
                    try container.viewContext.save()
                    
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(
                            name: .taskFailedNotification,
                            object: nil,
                            userInfo: ["failedTasks": updatedTasks]
                        )
                    }
                }
                
            } catch{
                print("Error while checking for failed deadlines: \(error)")
                container.viewContext.rollback()
            }
        }
    }
    
    private func scheduleBackgroundTask() {
        
    }
    
    /*
     withTimeInterval: seconds
     */
    func scheduleDeadlineCheck(){
        // check up front in case app was closed
        checkForFailedDeadlines()
        scheduleBackgroundTask()
        Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { [weak self] _ in
            self?.checkForFailedDeadlines()
        }
    }
}

extension Notification.Name {
    static let taskFailedNotification = Notification.Name("taskFailedNotification")
}

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
import BackgroundTasks
import OSLog
// Main data manager to handle the PinTask items
class DataManager: NSObject, ObservableObject {
    
    static let shared = DataManager()
    
    /// Dynamic properties that the UI will react to
    @Published var todos: [PinTask] = [PinTask]()
    @Published var alertItem: AlertItem?
    
    private var foregroundTimer: Timer?
    
    // Add the Core Data container with the model name
    let container: NSPersistentContainer = NSPersistentContainer(name: "PinTaskList")
    
    // Default init method. Load the Core Data container
    override init() {
        super.init()
        container.loadPersistentStores { _, _ in }
        migrateExistingTasks()
        
        foregroundTimer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { [weak self] _ in
            self?.checkForFailedDeadlines()
        }
        checkForFailedDeadlines()
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
        print("Checking tasks within 50m of user location: \(userLocation)")
        let filteredTasks = filterPinTasksInBoundingBox(boundingBox: boundingbox, context: context)
        print("Found \(filteredTasks.count) tasks in bounding box")
        
        for pinTask in filteredTasks {
            let taskLocation = CLLocationCoordinate2D(
                latitude: pinTask.latitude,
                longitude: pinTask.longitude
            )
            
            let distance = LocationUtils.haversineDistance(
                from: userLocation,
                to: taskLocation
            )
            
            print("Task '\(pinTask.title ?? "untitled")' details:")
            print("- Task location: \(taskLocation)")
            print("- Distance from user: \(distance) meters")
            print("- Within range? \(distance <= 50 ? "Yes" : "No")")
            
            if distance <= 50 {
                print("🗑️ Removing task within range: \(pinTask.title ?? "untitled")")
                context.delete(pinTask)
            }
        }
        
        // Save changes after all deletions
        do {
            if context.hasChanges {
                try context.save()
                print("✅ Changes saved - tasks removed")
            } else {
                print("ℹ️ No changes to save")
            }
        } catch {
            print("❌ Error saving context: \(error)")
            alertItem = AlertItem(
                title: Text("Error"),
                message: Text("Unable to delete completed tasks."),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    func migrateExistingTasks() {
        print("Starting migration of existing tasks")
        let fetchRequest: NSFetchRequest<PinTask> = PinTask.fetchRequest()
        
        fetchRequest.predicate = NSPredicate(format: "status == nil OR status == ''")
        
        container.viewContext.performAndWait {
            do {
                let tasksToMigrate = try container.viewContext.fetch(fetchRequest)
                print("Found \(tasksToMigrate.count) tasks to migrate")
                
                for task in tasksToMigrate {
                    task.status = TaskStatus.active.rawValue
                    print("Migrated task: \(task.title ?? "untitled")")
                }
                
                if container.viewContext.hasChanges {
                    try container.viewContext.save()
                    print("Migration completed successfully")
                }
            } catch {
                print("Migration error: \(error)")
                container.viewContext.rollback()
            }
        }
    }
    
    // Clean up when DataManager is deallocated
    deinit {
        NotificationCenter.default.removeObserver(self)
        foregroundTimer?.invalidate()
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
    
    func setupAppStateObservers() {
        // Check for failed deadlines when app becomes active
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(checkFailedDeadlinesOnActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }
    
    @objc private func checkFailedDeadlinesOnActive() {
        os_log("App became active - checking deadlines", log: .app, type: .debug)
        checkForFailedDeadlines()
    }
    
    
    func checkForFailedDeadlines() {
        let now = Date()
        os_log("Checking for failed deadlines at %{public}@", log: .data, type: .debug, now.description)
        
        let backgroundContext = container.newBackgroundContext()
        backgroundContext.perform {
            do {
                // First check for all active tasks that passed their deadline
                let activeTasksFetch: NSFetchRequest<PinTask> = PinTask.fetchRequest()
                
                // Explicitly log all active tasks to see what we're working with
                let allActiveTasks = try backgroundContext.fetch(PinTask.fetchRequest())
                os_log("Total tasks in database: %d", log: .data, type: .debug, allActiveTasks.count)
                
                for task in allActiveTasks {
                    os_log("Task: %{public}@, Status: %{public}@, Deadline: %{public}@",
                           log: .data, type: .debug,
                           task.title ?? "untitled",
                           task.status,
                           task.deadline?.description ?? "no deadline")
                }
                
                activeTasksFetch.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
                    NSPredicate(format: "status == %@", TaskStatus.active.rawValue),
                    NSPredicate(format: "deadline < %@", now as NSDate)
                ])
                
                let newlyFailedTasks = try backgroundContext.fetch(activeTasksFetch)
                os_log("Found %d newly failed tasks", log: .data, type: .debug, newlyFailedTasks.count)
                
                if !newlyFailedTasks.isEmpty {
                    for task in newlyFailedTasks {
                        task.taskStatus = .failed
                        os_log("Marking task '%{public}@' as failed", log: .data, type: .debug, task.title ?? "untitled")
                    }
                    
                    try backgroundContext.save()
                    
                    let failedTaskObjectIDs = newlyFailedTasks.map { $0.objectID }
                    
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }
                        let mainContextTasks = failedTaskObjectIDs.compactMap {
                            self.container.viewContext.object(with: $0) as? PinTask
                        }
                        
                        if !mainContextTasks.isEmpty {
                            os_log("Posting notification for %d failed tasks", log: .data, type: .debug, mainContextTasks.count)
                            NotificationCenter.default.post(
                                name: .taskFailedNotification,
                                object: nil,
                                userInfo: ["failedTasks": mainContextTasks]
                            )
                        }
                    }
                }
            } catch {
                os_log("Error checking for failed deadlines: %{public}@", log: .data, type: .error, error.localizedDescription)
                backgroundContext.rollback()
            }
        }
    }
}

extension Notification.Name {
    static let taskFailedNotification = Notification.Name("taskFailedNotification")
}

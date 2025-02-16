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
// Main data manager to handle the PinTask items
class DataManager: NSObject, ObservableObject {
    
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
    
    func checkForFailedDeadlines() {
        print("\n--- Checking for failed deadlines ---")
        let fetchRequest: NSFetchRequest<PinTask> = PinTask.fetchRequest()
        
        // First get all tasks for logging
        do {
            let allTasks = try container.viewContext.fetch(fetchRequest)
            print("Total tasks in database: \(allTasks.count)")
            print("All tasks:")
            for task in allTasks {
                print("- Title: \(task.title ?? "untitled"), Deadline: \(task.deadline?.description ?? "no deadline"), Status: \(task.status)")
            }
        } catch {
            print("Error fetching all tasks: \(error)")
        }
        
        let now = Date()
        print("Current date: \(now)")
        
        container.viewContext.performAndWait {
            do {
                var updatedTasksDict: [UUID: PinTask] = [:]  // Use dictionary instead of Set
                
                // First check for newly failed tasks
                let activeTasksFetch: NSFetchRequest<PinTask> = PinTask.fetchRequest()
                activeTasksFetch.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
                    NSPredicate(format: "status == %@", TaskStatus.active.rawValue),
                    NSPredicate(format: "deadline != nil AND deadline < %@", now as NSDate)
                ])
                
                let newlyFailedTasks = try container.viewContext.fetch(activeTasksFetch)
                print("Found \(newlyFailedTasks.count) newly failed tasks")
                
                for task in newlyFailedTasks {
                    print("New failed task details:")
                    print("- Title: \(task.title ?? "untitled")")
                    print("- Deadline: \(task.deadline?.description ?? "no deadline")")
                    print("- Status: \(task.status)")
                    print("- Is deadline past? \(task.deadline?.compare(now) == .orderedAscending ? "Yes" : "No")")
                    
                    task.taskStatus = .failed
                    if let id = task.id {
                        updatedTasksDict[id] = task
                        let content = UNMutableNotificationContent()
                        content.title = "Task Failed"
                        content.body = "Your task \"\(task.title ?? "untitled\"")\" has passed its deadline."
                        content.sound = .default
                        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
                        let request = UNNotificationRequest(
                            identifier: id.uuidString,
                            content: content,
                            trigger: trigger
                        )
                        UNUserNotificationCenter.current().add(request) { error in
                            if let error = error {
                                print("Error adding notification: \(error)")
                            }
                        }
                    }
                    print("Marked new task as failed: \(task.title ?? "untitled")")
                }
                
                // Now fetch all existing failed tasks
                let failedTasksFetch: NSFetchRequest<PinTask> = PinTask.fetchRequest()
                failedTasksFetch.predicate = NSPredicate(format: "status == %@", TaskStatus.failed.rawValue)
                
                let existingFailedTasks = try container.viewContext.fetch(failedTasksFetch)
                print("Found \(existingFailedTasks.count) existing failed tasks")
                
                // Add existing failed tasks to dictionary
                for task in existingFailedTasks {
                    if let id = task.id {
                        updatedTasksDict[id] = task
                    }
                }
                
                let updatedTasks = Array(updatedTasksDict.values)
                
                if !updatedTasks.isEmpty {
                    if container.viewContext.hasChanges {
                        try container.viewContext.save()
                        print("Saved changes to Core Data")
                    }
                    
                    print("Posting notification for \(updatedTasks.count) total failed tasks")
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(
                            name: .taskFailedNotification,
                            object: nil,
                            userInfo: ["failedTasks": updatedTasks]
                        )
                    }
                } else {
                    print("No failed tasks to process")
                }
                
            } catch {
                print("Error while checking for failed deadlines: \(error)")
                container.viewContext.rollback()
            }
        }
    }
    
    public func scheduleBackgroundTask() {
        let request = BGProcessingTaskRequest(identifier: "Jason.DoItOrLoseIt.deadlinecheck")
        request.requiresNetworkConnectivity = false
        request.requiresExternalPower = false
        request.earliestBeginDate = Date(timeIntervalSinceNow: 300)
        
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Could not schedule background task: \(error)")
        }
    }
    
    /*
     Invalidate existing timer if any
     Create new timer that fires every 5 seconds
     */
    private func startForegroundTimer() {
        foregroundTimer?.invalidate()
        foregroundTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { [weak self] _ in
            print("Foreground timer fired - checking deadlines")
            self?.checkForFailedDeadlines()
        }
    }
    
    /*
     Stop the frequent foreground timer
     Schedule background task (already set to 5 minutes)
     */
    @objc private func appMovedToBackground() {
        print("App moved to background")
        foregroundTimer?.invalidate()
        foregroundTimer = nil
        scheduleBackgroundTask()
    }
    
    // Restart the frequent foreground timer
    @objc private func appMovedToForeground() {
        print("App moved to foreground")
        startForegroundTimer()
    }
    
    func scheduleDeadlineCheck() {
        print("Scheduling deadline check")
        checkForFailedDeadlines()
        scheduleBackgroundTask()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appMovedToBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appMovedToForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
        startForegroundTimer()
    }
    
}

extension Notification.Name {
    static let taskFailedNotification = Notification.Name("taskFailedNotification")
}

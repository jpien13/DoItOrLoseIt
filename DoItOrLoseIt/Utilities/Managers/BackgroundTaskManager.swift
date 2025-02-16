//
//  BackgroundTaskManager.swift
//  DoItOrLoseIt
//
//  Created by Jason Pien on 2/15/25.
//

import BackgroundTasks

class BackgroundTaskManager: ObservableObject {
    private let dataManager: DataManager
    private let processingTaskId = "Jason.DoItOrLoseIt.deadlinecheck"
    private let refreshTaskId = "Jason.DoItOrLoseIt.refresh"
    
    init(dataManager: DataManager) {
        self.dataManager = dataManager
        

        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: processingTaskId,
            using: .main
        ) { [weak self] task in
            guard let self = self,
                  let backgroundTask = task as? BGProcessingTask else { return }
            self.handleProcessingTask(backgroundTask)
        }
        

        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: refreshTaskId,
            using: .main
        ) { [weak self] task in
            guard let self = self,
                  let refreshTask = task as? BGAppRefreshTask else { return }
            self.handleRefreshTask(refreshTask)
        }
        

        scheduleAppRefresh()
        dataManager.scheduleBackgroundTask()
    }
    
    private func handleProcessingTask(_ task: BGProcessingTask) {
        let taskGroup = DispatchGroup()
        taskGroup.enter()
        
        task.expirationHandler = {
            print("Processing task expired")
            task.setTaskCompleted(success: false)
        }
        
        DispatchQueue.global(qos: .utility).async {
            print("Starting processing task execution")
            self.dataManager.checkForFailedDeadlines()
            self.dataManager.scheduleBackgroundTask()
            taskGroup.leave()
        }
        
        taskGroup.notify(queue: .main) {
            print("Processing task completed")
            task.setTaskCompleted(success: true)
        }
    }
    
    private func handleRefreshTask(_ task: BGAppRefreshTask) {
        task.expirationHandler = {
            print("Refresh task expired")
            task.setTaskCompleted(success: false)
        }
        
        DispatchQueue.global(qos: .utility).async {
            print("Starting refresh task execution")
            self.dataManager.checkForFailedDeadlines()
            self.scheduleAppRefresh()
            task.setTaskCompleted(success: true)
        }
    }
    
    private func scheduleAppRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: refreshTaskId)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 5 * 60)
        
        do {
            try BGTaskScheduler.shared.submit(request)
            print("Successfully scheduled app refresh task")
        } catch {
            print("Could not schedule app refresh: \(error)")
        }
    }
}

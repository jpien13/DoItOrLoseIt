//
//  BackgroundTaskManager.swift
//  DoItOrLoseIt
//
//  Created by Jason Pien on 2/15/25.
//

import BackgroundTasks
import OSLog

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

        task.expirationHandler = {
            os_log("Processing task expired", log: .background, type: .info)
            task.setTaskCompleted(success: false)
        }
        
        DispatchQueue.global(qos: .utility).async {
            os_log("Executing background processing task", log: .background, type: .debug)
            self.dataManager.checkForFailedDeadlines()
            self.dataManager.scheduleBackgroundTask()
            task.setTaskCompleted(success: true)
        }
    }
    
    private func handleRefreshTask(_ task: BGAppRefreshTask) {
        task.expirationHandler = {
            os_log("Refresh task expired", log: .background, type: .info)
            task.setTaskCompleted(success: false)
        }
        
        DispatchQueue.global(qos: .utility).async {
            os_log("Executing background refresh task", log: .background, type: .debug)
            self.dataManager.checkForFailedDeadlines()
            self.scheduleAppRefresh()
            task.setTaskCompleted(success: true)
        }
    }
    
    private func scheduleAppRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: refreshTaskId)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60)
        
        do {
            try BGTaskScheduler.shared.submit(request)
            os_log("Successfully scheduled app refresh task", log: .background, type: .debug)
        } catch {
            os_log("Failed to schedule app refresh: %{public}@", log: .background, type: .error, error.localizedDescription)
        }
    }
}

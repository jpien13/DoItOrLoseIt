//
//  BackgroundTaskManager.swift
//  DoItOrLoseIt
//
//  Created by Jason Pien on 2/15/25.
//

import BackgroundTasks

class BackgroundTaskManager: ObservableObject {
    private let dataManager: DataManager
    
    init(dataManager: DataManager) {
        self.dataManager = dataManager
        
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: "Jason.DoItOrLoseIt.deadlinecheck",
            using: nil
        ) { [weak self] task in
            guard let self = self,
                  let backgroundTask = task as? BGProcessingTask else { return }
            
            self.handleBackgroundTask(backgroundTask)
        }
    }
    
    private func handleBackgroundTask(_ task: BGProcessingTask) {
        dataManager.scheduleBackgroundTask()
        
        task.expirationHandler = {
        }
        
        dataManager.checkForFailedDeadlines()
        
        task.setTaskCompleted(success: true)
    }
}

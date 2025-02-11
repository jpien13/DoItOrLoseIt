//
//  DataManager.swift
//  DoItOrLoseIt
//
//  Created by Jason Pien on 2/11/25.
//

import CoreData
import Foundation

// Main data manager to handle the PinTask items
class DataManager: NSObject, ObservableObject {
    
    // Add the Core Data container with the model name
    let container: NSPersistentContainer = NSPersistentContainer(name: "PinTaskList")
    
    // Default init method. Load the Core Data container
    override init() {
        super.init()
        container.loadPersistentStores { _, _ in }
    }
}

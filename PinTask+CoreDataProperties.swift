//
//  PinTask+CoreDataProperties.swift
//  DoItOrLoseIt
//
//  Created by Jason Pien on 2/11/25.
//
//

import Foundation
import CoreData


extension PinTask {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PinTask> {
        return NSFetchRequest<PinTask>(entityName: "PinTask")
    }
    @NSManaged public var title: String?
    @NSManaged public var deadline: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var longitude: Double
    @NSManaged public var latitude: Double
    @NSManaged public var challengeAmount: Double
    @NSManaged public var status: String

}

extension PinTask {
    var taskStatus: TaskStatus {
        get {
            TaskStatus(rawValue: status) ?? .active
        }
        set {
            status = newValue.rawValue
        }
    }
}

enum TaskStatus: String {
    case active = "active"
    case completed = "completed"
    case failed = "failed"
}

extension PinTask : Identifiable {

}

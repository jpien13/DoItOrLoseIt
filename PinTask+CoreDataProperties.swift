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
    @NSManaged public var wager: Double

}

extension PinTask : Identifiable {

}

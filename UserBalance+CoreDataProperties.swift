//
//  UserBalance+CoreDataProperties.swift
//  DoItOrLoseIt
//
//  Created by Jason Pien on 3/15/25.
//
//

import Foundation
import CoreData


extension UserBalance {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserBalance> {
        return NSFetchRequest<UserBalance>(entityName: "UserBalance")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var amount: Double
    @NSManaged public var lastUpdated: Date?

}

extension UserBalance : Identifiable {

}

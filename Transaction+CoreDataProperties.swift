//
//  Transaction+CoreDataProperties.swift
//  DoItOrLoseIt
//
//  Created by Jason Pien on 3/15/25.
//
//

import Foundation
import CoreData


extension Transaction {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Transaction> {
        return NSFetchRequest<Transaction>(entityName: "Transaction")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var amount: Double
    @NSManaged public var type: String?
    @NSManaged public var transactionDescription: String?
    @NSManaged public var date: Date?
    @NSManaged public var taskId: UUID?

}

enum TransactionType: String {
    case deposit = "deposit"
    case wager = "wager"
    case refund = "refund"
}

extension Transaction {
    var transactionType: TransactionType {
        get {
            return TransactionType(rawValue: type ?? "unknown") ?? .deposit
        } set {
            type = newValue.rawValue
        }
    }
}

extension Transaction : Identifiable {

}

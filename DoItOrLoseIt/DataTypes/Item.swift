//
//  Item.swift
//  DoItOrLoseIt
//
//  Created by Jason Pien on 1/23/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}

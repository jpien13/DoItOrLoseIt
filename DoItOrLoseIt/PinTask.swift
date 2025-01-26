//
//  PinTask.swift
//  DoItOrLoseIt
//
//  Created by Jason Pien on 1/25/25.
//

import Foundation

struct PinTask: Hashable, Identifiable {
    
    let id = UUID()
    let longitude: Double
    let latitude: Double
    let wager: Double
    let deadline: String
    
    init(longitude: Double, latitude: Double, wager: Double, deadline: String) {
        self.longitude = longitude
        self.latitude = latitude
        self.wager = wager
        self.deadline = deadline
    }
    
}


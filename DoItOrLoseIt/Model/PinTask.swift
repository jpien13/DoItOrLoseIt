//
//  PinTask.swift
//  DoItOrLoseIt
//
//  Created by Jason Pien on 1/25/25.
//

import Foundation

// ============================================
// The MODEL that defines the structure of data
// (M in MVVM Model-View-ViewModel)
// ============================================

struct PinTask: Codable, Equatable, Hashable, Identifiable {
    
    let id: UUID
    let longitude: Double
    let latitude: Double
    let wager: Double
    let deadline: String
    
    init(longitude: Double, latitude: Double, wager: Double, deadline: String) {
        self.id = UUID()
        self.longitude = longitude
        self.latitude = latitude
        self.wager = wager
        self.deadline = deadline
    }
    
}


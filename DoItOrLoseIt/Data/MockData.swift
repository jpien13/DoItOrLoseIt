//
//  MockData.swift
//  DoItOrLoseIt
//
//  Created by Jason Pien on 1/25/25.
//

import Foundation

struct MockData {
    
    static let samplePinTask = PinTaskDummy(longitude: 69.0,
                                       latitude: 420.430,
                                       wager: 5.00,
                                       deadline: "7:00 PM")
    
    static let pinTasks = [
        PinTaskDummy(longitude: -71.397416,
               latitude: 41.830096,
               wager: 5.00,
               deadline: "7:00 PM"),
        PinTaskDummy(longitude: -71.389567,
                latitude: 41.817417,
               wager: 2.00,
               deadline: "4:20 PM"),
        PinTaskDummy(longitude: -71.403303,
                 latitude: 41.825924,
                 wager: 9.99,
                 deadline: "9:00 AM")
    ]
}


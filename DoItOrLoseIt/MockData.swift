//
//  MockData.swift
//  DoItOrLoseIt
//
//  Created by Jason Pien on 1/25/25.
//

import Foundation

struct MockData {
    
    static let samplePinTask = PinTask(longitude: 69.0,
                                       latitude: 420.430,
                                       wager: 5.00,
                                       deadline: "7:00 PM")
    
    static let pinTasks = [
        PinTask(longitude: 69.0,
               latitude: 420.430,
               wager: 5.00,
               deadline: "7:00 PM"),
        PinTask(longitude: -3123.5,
                latitude: 233.42,
               wager: 2.00,
               deadline: "4:20 PM"),
        PinTask(longitude: 31.73,
                 latitude: -45.12,
                 wager: 9.99,
                 deadline: "9:00 AM"),
        PinTask(longitude: 6.42,
               latitude: 4.1,
               wager: 1.00,
               deadline: "1:00 PM"),
        PinTask(longitude: -979.0,
               latitude: 41.91,
               wager: 2.00,
               deadline: "7:30 PM")
    ]
}

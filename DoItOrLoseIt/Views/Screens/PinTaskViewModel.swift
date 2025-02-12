//
//  PinTaskViewModel.swift
//  DoItOrLoseIt
//
//  Created by Jason Pien on 1/28/25.
//

import SwiftUI
import MapKit

// =============================================================
// A VIEWMODEL that bridges the VIEW and MODEL, providing methods
// to manipulate and fetch the data. In this case, it manages
// the list of PinTask items and makes them available to VIEWS
//
// (VM in MVVM Model-View-ViewModel)
// =============================================================

class PinTaskViewModel: NSObject, ObservableObject {
    
    @Published var alertItem: AlertItem?
    @Published var pinTasks = [PinTaskDummy]() // @Published to notify Views of data changes
    
    func addPinTask(coordinate: CLLocationCoordinate2D) {
        let newCoordinate = PinTaskDummy(longitude: coordinate.longitude,
                                    latitude: coordinate.latitude,
                                    wager: 12.34,
                                    deadline: "This is a test")
        pinTasks.append(newCoordinate)
    }
    
    func removePinTask(_ task: PinTaskDummy) {
        pinTasks.removeAll { $0.id == task.id }
    }
    
    
    

}




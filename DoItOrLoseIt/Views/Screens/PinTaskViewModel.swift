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
    
    func filterPinTasksInBoundingBox(boundingBox: (southWest: CLLocationCoordinate2D, northEast: CLLocationCoordinate2D)) -> [PinTaskDummy] {
        return pinTasks.filter { pinTask in
            
            let isLatitudeInRange = pinTask.latitude >= boundingBox.southWest.latitude &&
                                    pinTask.latitude <= boundingBox.northEast.latitude
            
            let isLongitudeInRange = pinTask.longitude >= boundingBox.southWest.longitude &&
                                     pinTask.longitude <= boundingBox.northEast.longitude
            
            return isLatitudeInRange && isLongitudeInRange
        }
    }
    
    func removePinTasksWithin50Meters(userLocation: CLLocationCoordinate2D, boundingbox: (southWest: CLLocationCoordinate2D, northEast: CLLocationCoordinate2D)){
        
        let filteredTasks = filterPinTasksInBoundingBox(boundingBox: boundingbox)
        for pinTask in filteredTasks {
            let distance = LocationUtils.haversineDistance(
                from: userLocation,
                to: CLLocationCoordinate2D(
                    latitude: pinTask.latitude,
                    longitude: pinTask.longitude)
            )
            if distance <= 50 {
                removePinTask(pinTask)
            }
        }
    }

}




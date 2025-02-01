//
//  AlertItem.swift
//  DoItOrLoseIt
//
//  Created by Jason Pien on 2/1/25.
//

import SwiftUI

struct AlertItem: Identifiable {
    let id = UUID()
    let title: Text
    let message: Text
    let dismissButton: Alert.Button
}

struct AlertContext {
    static let unableToGetLocations = AlertItem(title: Text("Locations Error"),
                                                message: Text("Unable to retrieve locations at thi time. \nPlease try again."),
                                                dismissButton: .default(Text("Ok")))
    
    static let locationRestricted = AlertItem(title: Text("Locations Restricted"),
                                                message: Text("Your location is restricted. This may be due to parental controls."),
                                                dismissButton: .default(Text("Ok")))
    
    static let locationDenied = AlertItem(title: Text("Locations Denied"),
                                                message: Text("App does not have permission to access your location. To change that, go to your phone's Settings."),
                                                dismissButton: .default(Text("Ok")))
    
    static let locationDisabled = AlertItem(title: Text("Location Services Disabled"),
                                                message: Text("Your phone's location services are disabled. To change that, go to your phone's Settings."),
                                                dismissButton: .default(Text("Ok")))
}

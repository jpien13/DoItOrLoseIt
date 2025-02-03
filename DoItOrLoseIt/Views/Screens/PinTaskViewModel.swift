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
    @Published var pinTasks: [PinTask] = MockData.pinTasks // @Published to notify Views of data changes

}
    // TODO: methods to add and remove tasks


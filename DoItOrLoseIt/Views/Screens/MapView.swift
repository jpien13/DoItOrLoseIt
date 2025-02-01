//
//  MapView.swift
//  DoItOrLoseIt
//
//  Created by Jason Pien on 1/23/25.
//

import SwiftUI
import MapKit

// =============================================================
// A VIEW that renders the UI displaying data from the VIEWMODEL
// (V in MVVM Model-View-ViewModel)
// =============================================================

struct MapView: View {
    
    @EnvironmentObject var viewModel: PinTaskViewModel
    
    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 41.826084,
                                                                                  longitude: -71.403246),
                                                   span: MKCoordinateSpan(latitudeDelta: 0.005,
                                                                          longitudeDelta: 0.005))
        
    var body: some View {
        ZStack {
            Map(coordinateRegion: $region,
                showsUserLocation: true,
                userTrackingMode: .constant(.follow),
                annotationItems: viewModel.pinTasks) { pinTask in
                MapMarker(coordinate: CLLocationCoordinate2D(latitude: pinTask.latitude,
                                                                 longitude: pinTask.longitude))
                
            }
        }
        .onAppear {
            viewModel.checkIfLocationServicesIsEnabled()
        }
        .alert(item: $viewModel.alertItem) { alertItem in
            Alert(title: alertItem.title,
                      message: alertItem.message,
                      dismissButton: alertItem.dismissButton)
        }
    }
}

#Preview {
    MapView()
        .environmentObject(PinTaskViewModel())
}

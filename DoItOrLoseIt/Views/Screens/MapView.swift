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

// TODO: Track down and fix deprecated func/calls

struct MapView: View {
    
    @EnvironmentObject var viewModel: PinTaskViewModel
    @EnvironmentObject private var locationManager: LocationManager
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(
            latitude: 41.826084,
            longitude: -71.403246
        ),
        span: MKCoordinateSpan(
            latitudeDelta: 0.005,
            longitudeDelta: 0.005
        )
    )
    
    @State private var isOnUserLocation = true
    @State private var userTrackingMode: MapUserTrackingMode = .follow
    
    var body: some View {
        ZStack {
            Map(coordinateRegion: $region,
                showsUserLocation: true,
                userTrackingMode: $userTrackingMode,
                annotationItems: viewModel.pinTasks) { pinTask in
                MapMarker(coordinate: CLLocationCoordinate2D(
                    latitude: pinTask.latitude,
                    longitude: pinTask.longitude
                ))
            }
            .gesture(
                DragGesture()
                .onChanged{ _ in
                    isOnUserLocation = false
                    userTrackingMode = .none
                }
            )
            RecenterButton{
                isOnUserLocation = true
                userTrackingMode = .follow
                if let location = locationManager.userLocation {
                    withAnimation {
                        region.center = location
                        region.span = MKCoordinateSpan(
                            latitudeDelta: 0.005,
                            longitudeDelta: 0.005
                        )
                    }
                }
            }
                .padding()
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity,
                    alignment: .topTrailing
                )
                .shadow(radius: 10)
            
        }
        .onAppear {
            locationManager.checkIfLocationServicesIsEnable()
            if let location = locationManager.userLocation {
                region.center = location
                userTrackingMode = .follow
            }
        }
        .onChange(of: locationManager.isLocationReady) { ready in
            if ready && isOnUserLocation, let location = locationManager.userLocation {
                region.center = location
                userTrackingMode = .follow
            }
        }
        .alert(item: $locationManager.alertItem) { alertItem in
            Alert(
                title: alertItem.title,
                message: alertItem.message,
                dismissButton: alertItem.dismissButton
            )
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
        .environmentObject(LocationManager())
}

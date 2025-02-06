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
    
    @State private var cameraPosition: MapCameraPosition = .userLocation(fallback: .automatic)
    @State private var isOnUserLocation = true
    
    var body: some View {
        ZStack {
            MapReader { proxy in
                Map(position: $cameraPosition) {
                    ForEach(viewModel.pinTasks) { pinTask in
                        Marker("Task", coordinate: CLLocationCoordinate2D(
                            latitude: pinTask.latitude,
                            longitude: pinTask.longitude)
                        )
                    }
                }
                .mapStyle(.standard)
                .onTapGesture { position in
                    if let coordinate = proxy.convert(position, from: .local) {
                        print(coordinate)
                        let newPinTask = PinTask(longitude: coordinate.longitude, latitude: coordinate.latitude, wager: 1.00, deadline: "7:00 PM")
                        viewModel.pinTasks.append(newPinTask)
                    }
                }
                .gesture(
                    DragGesture()
                    .onChanged{ _ in
                        isOnUserLocation = false
                        cameraPosition = .automatic
                    }
                )
            }
            VStack {
                Spacer()
                    .frame(height: 60)
                HStack {
                    Spacer()
                    RecenterButton(
                        isOnUserLocation: $isOnUserLocation,
                        cameraPosition: $cameraPosition
                    )
                        .padding()
                        .shadow(radius: 10)
                }
                Spacer()
            }
            
            
        }
        .onAppear {
            locationManager.checkIfLocationServicesIsEnable()
        }
        .onChange(of: locationManager.isLocationReady) { ready in
            if ready && isOnUserLocation{
                cameraPosition = .userLocation(fallback: .automatic)
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

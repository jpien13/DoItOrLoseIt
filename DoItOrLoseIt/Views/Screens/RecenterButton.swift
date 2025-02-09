//
//  RecenterButton.swift
//  DoItOrLoseIt
//
//  Created by Jason Pien on 2/3/25.
//

import SwiftUI
import MapKit

struct RecenterButton: View {
    
    @EnvironmentObject private var locationManager: LocationManager
    @Binding var isOnUserLocation: Bool
    @Binding var cameraPosition: MapCameraPosition
    @State private var didTap: Bool = false
    
    var body: some View {
        Button(action: {
            recenterToUserLocation()
            self.didTap = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                didTap = false
            }}
        ) {
            Image(systemName: (didTap ? "location.fill" : "location"))
                .resizable()
                .padding(15)
                .foregroundColor(Color.gray)
                .frame(
                    width: 50,
                    height: 50
                )
                .background(Color.white)
                .cornerRadius(10)
        }
        .padding()
        
    }
    
    private func recenterToUserLocation() {
        isOnUserLocation = true
        cameraPosition = .userLocation(fallback: .region(
            MKCoordinateRegion(
                center: locationManager.userLocation?.coordinate ?? CLLocationCoordinate2D(latitude: 0, longitude: 0),
                span: MKCoordinateSpan(
                    latitudeDelta: 0.005,
                    longitudeDelta: 0.005
                )
            )
        ))
    }
}

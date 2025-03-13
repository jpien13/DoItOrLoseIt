//
//  TaskItemView.swift
//  DoItOrLoseIt
//
//  Created by Jason Pien on 1/25/25.
//

import SwiftUI
import CoreLocation
import OSLog

struct TaskItemView: View {
    @Environment(\.managedObjectContext) var viewContext
    @EnvironmentObject var dataManager: DataManager
    
    let pinTask: PinTask
    @State private var address: String = "Loading address..."
    
    var body: some View {
       
        VStack {
            HStack{
                Text("📍" + String(pinTask.title ?? "My Task"))
                    .fontWeight(.bold)
                Spacer()
            }
            .padding(.horizontal)
            HStack{
                Text(address)
                Spacer()
                Text("$ ") + Text(String(format: "%.2f", pinTask.challengeAmount))
            }
            .padding(.horizontal)
            HStack {
                if let deadline = pinTask.deadline {
                    Text(formatDate(deadline))
                }
                Spacer()
            }
            .padding(.horizontal)
            
            
        }
        .frame(width: 350, height: 90)
        .foregroundColor(Color.black)
        .background(Color.white)
        .cornerRadius(10)
        .padding(.horizontal)
        .shadow(radius: 3)
        .onAppear {
            reverseGeocoding(latitude: pinTask.latitude, longitude: pinTask.longitude)
        }
    
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func reverseGeocoding(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: latitude, longitude: longitude)
        
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            DispatchQueue.main.async {
                if let error = error {
                    self.address = "Address unavailable"
                    os_log("Geocoding failed - %{public}@", log: .location, type: .error, error.localizedDescription)
                    return
                }
                
                if let placemarks = placemarks, let placemark = placemarks.first {
                    
                    if let areasOfInterest = placemark.areasOfInterest, !areasOfInterest.isEmpty {
                        self.address = areasOfInterest[0]
                        return
                    }
                    if let name = placemark.name {
                        self.address = name
                        return
                    }
                    let addressComponents = [
                        placemark.locality,            // City
                        placemark.administrativeArea   // State
                    ].compactMap { $0 }
                    
                    self.address = addressComponents.joined(separator: ", ")
                } else {
                    self.address = "Address not found"
                }
            }
        }
    }
    
}

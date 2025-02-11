//
//  PinTaskInputForm.swift
//  DoItOrLoseIt
//
//  Created by Jason Pien on 2/11/25.
//

import SwiftUI
import MapKit

struct PinTaskInputForm: View {
    
    @Environment(\.dismiss) private var dismiss
    // MARK: Core data variables
    @EnvironmentObject var manager: DataManager
    @Environment(\.managedObjectContext) var viewContext
    
    let coordinate: CLLocationCoordinate2D
    var onSave: (CLLocationCoordinate2D) -> Void
    
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    Text("Latitude: \(coordinate.latitude)")
                    Text("Longitude: \(coordinate.longitude)")
                }
                
                // TODO: Add wager input fields here
            }
            .navigationTitle("Add New Pin")
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                },
                trailing: Button("Save") {
                    onSave(coordinate)
                    dismiss()
                }
            )
        }
    }
}

#Preview {
    let mockCoordinate = CLLocationCoordinate2D(
        latitude: 41.826084,
        longitude: -71.403246
    )
    
    return PinTaskInputForm(
        coordinate: mockCoordinate,
        onSave: { _ in
            print("Save tapped in preview")
        }
    )
}

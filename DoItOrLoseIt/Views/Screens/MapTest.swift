//
//  MapTest.swift
//  DoItOrLoseIt
//
//  Created by Jason Pien on 2/5/25.
//

import SwiftUI
import MapKit

struct MapTest: View {
    
    let startPosition = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 56, longitude: -3), span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10)
        )
    )
    var body: some View {
        MapReader { proxy in
            Map(initialPosition: startPosition)
                .onTapGesture {position in
                    if let coordinate = proxy.convert(position, from: .local) {
                        print(coordinate)
                    }
                        
                }
        }
    }
}

#Preview {
    MapTest()
}

//
//  LocationUtils.swift
//  DoItOrLoseIt
//
//  Created by Jason Pien on 2/8/25.
//

import CoreLocation

struct LocationUtils {
    static func haversineDistance(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> Double {
        let earthRadius = 6371.009
        
        let lat1 = from.latitude * .pi / 180
        let lon1 = from.longitude * .pi / 180
        let lat2 = to.latitude * .pi / 180
        let lon2 = to.longitude * .pi / 180
        
        let deltaLat = lat2 - lat1
        let deltaLon = lon2 - lon1
        
        let a = sin(deltaLat / 2) * sin(deltaLat / 2) + cos(lat1) * cos(lat2) * sin(deltaLon / 2) * sin(deltaLon / 2)
        let c = 2 * atan2(sqrt(a), sqrt(1 - a))
        
        let distance = earthRadius * c * 1000
        return distance
    }
}

struct CoordinateWrapper: Equatable {
    let coordinate: CLLocationCoordinate2D
    
    static func == (lhs: CoordinateWrapper, rhs: CoordinateWrapper) -> Bool {
        return lhs.coordinate.latitude == rhs.coordinate.latitude && lhs.coordinate.longitude == rhs.coordinate.longitude
    }
}

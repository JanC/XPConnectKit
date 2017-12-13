//
//  XPCPosition.swift
//  XPConnectKit
//
//  Created by Jan Chaloupecky on 13.12.17.
//  Copyright © 2017 TequilaApps. All rights reserved.
//

import Foundation
import CoreLocation

public struct XPCPosition {
    
    enum Indexes: Int {
        case lat = 0
        case long = 1
        case elevation = 2
        case roll = 3
        case pitch = 4
        case heading = 5
        case gear = 6
        
        static var count: Int { return Indexes.gear.rawValue + 1}
    }
    
    let aircraftId: Int
    let location: CLLocation
    let roll: Float
    let pitch: Float
    let heading: Float
    
    init?(aircraftId: Int, values: [Float]) {
        if(values.count != Indexes.count) {
            return nil
        }
        self.aircraftId = aircraftId
        let coordinates = CLLocationCoordinate2D(latitude: Double(values[Indexes.lat.rawValue]), longitude: Double(values[Indexes.long.rawValue]))
        
        location = CLLocation(coordinate: coordinates, altitude: Double(values[Indexes.elevation.rawValue]), horizontalAccuracy: 1, verticalAccuracy: 1, timestamp: Date())
        roll = values[Indexes.roll.rawValue]
        pitch = values[Indexes.pitch.rawValue]
        heading = values[Indexes.heading.rawValue]
    
    }
}

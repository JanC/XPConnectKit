//
//  XPLNode.swift
//  XPLKit
//
//  Created by Jan Chaloupecky on 28.11.17.
//  Copyright © 2017 TequilaApps. All rights reserved.
//

import Foundation

// Represent a running X-Plane instance
public struct XPLNode {
    public let address: String
    public var port: ushort {
        get {
            return beacon.port
        }
    }
    public let beacon: XPLBeacon
    
    init(address: String, beacon: XPLBeacon) {
        self.address = address
        self.beacon = beacon
    }
}

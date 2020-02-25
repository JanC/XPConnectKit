//
//  XPLBeacon.swift
//  XPLKit
//
//  Created by Jan Chaloupecky on 28.11.17.
//  Copyright © 2017 TequilaApps. All rights reserved.
//

import Foundation

public struct XPLBeacon {
    // XPlaneConnect server port e.g. '49009'
    public let port: ushort

    // X-Plane version e.g. '11260
    private let xplaneVersionCode: UInt32

    // XPlaneConnect plugin version e.g. '1.3-rc.1'
    public let xplaneConnectVersion: String

    public var xplaneVersion: String {

        return String(format: "%.2f", Double(xplaneVersionCode) / 100.0)
    }

    public init(port: ushort, xplaneVersionCode: UInt32, xplaneConnectVersion: String) {
        self.port = port
        self.xplaneVersionCode = xplaneVersionCode
        self.xplaneConnectVersion = xplaneConnectVersion
    }

}

extension XPLBeacon: Decodable {
    
    init(data: Data) {
        var offset = 0
        port = data.object(at: offset)
        offset = offset + MemoryLayout.size(ofValue: port)
        
        xplaneVersionCode = data.object(at: offset)
        offset = offset + MemoryLayout.size(ofValue: xplaneVersionCode)
        
        xplaneConnectVersion = data.subdata(in: offset..<data.count).withUnsafeBytes { (pointer: UnsafePointer<CChar>) -> String in
            return String(cString: pointer)
        }
    }
}

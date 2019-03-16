//
//  XPLBeacon.swift
//  XPLKit
//
//  Created by Jan Chaloupecky on 28.11.17.
//  Copyright © 2017 TequilaApps. All rights reserved.
//

import Foundation

public struct XPLBeacon {
    public let versionNumber: UInt32
    public let port: ushort
    public let computerName: String
    
    let majorVersion: UInt8
    let minorVersion: UInt8
    let applicationHostId: UInt32
    let role: UInt32

}

extension XPLBeacon: Decodable {
    
    init(data: Data) {
        var offset = 0
        majorVersion = data.object(at: offset)
        offset = offset + MemoryLayout.size(ofValue: majorVersion)
        
        minorVersion = data.object(at: offset)
        offset = offset + MemoryLayout.size(ofValue: minorVersion)
        
        applicationHostId = data.object(at: offset)
        offset = offset + MemoryLayout.size(ofValue: applicationHostId)
        
        versionNumber = data.object(at: offset)
        offset = offset + MemoryLayout.size(ofValue: versionNumber)
        
        role = data.object(at: offset)
        offset = offset + MemoryLayout.size(ofValue: role)
        
        port = data.object(at: offset)
        offset = offset + MemoryLayout.size(ofValue: port)
        
        
        computerName = data.subdata(in: offset..<data.count).withUnsafeBytes { (pointer: UnsafePointer<CChar>) -> String in
            return String(cString: pointer)
        }
    }
}

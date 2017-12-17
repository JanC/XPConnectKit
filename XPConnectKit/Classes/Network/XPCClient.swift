
//
//  XPPlaneConnect.swift
//  XPConnectKit
//
//  Created by Jan Chaloupecky on 04.12.17.
//  Copyright © 2017 TequilaApps. All rights reserved.
//

import Foundation
import xplaneconnect

public enum XPError: Error {
    case network
    case parsing(String)
}


public class XPCClient {
    
    let socket: XPCSocket
    
    public init(host: String) {
        
        let xpHost = host.cString(using: .utf8)!
        socket = openUDP(xpHost)
        
    }
    
    public func getPosition(aircraftId: Int = 0) throws -> XPCPosition {

        let size: Int32 = 7
        let values = UnsafeMutablePointer<Float>.allocate(capacity: Int(size))
        if(getPOSI(socket, values, Int8(aircraftId)) < 0 ) {
            throw XPError.network
        }
        let result = Array(UnsafeBufferPointer(start: values, count: Int(size)))
        
        return XPCPosition(aircraftId: aircraftId,values: result)!
        
    }
    
    public func get<P: Parser>(dref: String, parser: P) throws -> P.T {

        var size: Int32 = 50 // expected Size
        let pSize = UnsafeMutablePointer<Int32>(&size)
        let values = UnsafeMutablePointer<Float>.allocate(capacity: Int(size))
        
        if(getDREF(socket, dref.cString(using: .utf8)!, values, pSize) < 0) {
            throw XPError.network
        }
        
        let actualSize = pSize.withMemoryRebound(to: Int32.self, capacity: 1) { pointer in
            return pointer.pointee
        }
        
        let result = Array(UnsafeBufferPointer(start: values, count: Int(actualSize)))
        return try parser.parse(values: result)
}

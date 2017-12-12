
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
    case netowork
    case parsing(String)
}

public class XPPlaneConnect {
    

    
    let socket: XPCSocket
    
    public init(host: String) {
        
        let xpHost = host.cString(using: .utf8)!
        socket = openUDP(xpHost)
        
    }
    
    public func get<P: Parser>(dref: String, parser: P) throws -> P.T {

        var size: Int32 = 50 // expected Size
        let pSize = UnsafeMutablePointer<Int32>(&size)
        let values = UnsafeMutablePointer<Float>.allocate(capacity: Int(size))
        
        if(getDREF(socket, dref.cString(using: .utf8)!, values, pSize) < 0) {
            throw XPError.netowork
        }
        
        let actualSize = pSize.withMemoryRebound(to: Int32.self, capacity: 1) { pointer in
            return pointer.pointee
        }
        
//        print("actual size \(actualSize)")
        let result = Array(UnsafeBufferPointer(start: values, count: Int(actualSize)))
//        print("values: \(result)")
        
        return try parser.parse(values: result)
        
//
//        let chars = result.map() { CChar($0) }
//        print("chars: \(chars)")
//        let string: String = chars.withUnsafeBufferPointer { ptr in
//            let s = String(cString: ptr.baseAddress!)
//            return s
//        }
//        print("string: \(string)")
    }
}

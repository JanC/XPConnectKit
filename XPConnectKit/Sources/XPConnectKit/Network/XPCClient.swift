//
//  XPPlaneConnect.swift
//  XPConnectKit
//
//  Created by Jan Chaloupecky on 04.12.17.
//  Copyright © 2017 TequilaApps. All rights reserved.
//

import Foundation
import XPConnectKitC

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
        if getPOSI(socket, values, Int8(aircraftId)) < 0 {
            throw XPError.network
        }
        let result = Array(UnsafeBufferPointer(start: values, count: Int(size)))
        
        return XPCPosition(aircraftId: aircraftId, values: result)!
    }
    
    public func get(dref: String, expectedSize: Int32 = 255) throws -> [Float] {
        var size = expectedSize
        
        // get the pointer to the size
        let pSize = UnsafeMutablePointer<Int32>(&size)
        
        // allocate an float array with that size
        let values = UnsafeMutablePointer<Float>.allocate(capacity: Int(size))
    
        if getDREF(socket, dref.cString(using: .utf8)!, values, pSize) < 0 {
            throw XPError.network
        }
    
        // the content of exepcted size is now the actual size
        let actualSize = pSize.withMemoryRebound(to: Int32.self, capacity: 1) { pointer in
            return pointer.pointee
        }

        // copy the values
        let result = Array(UnsafeBufferPointer(start: values, count: Int(actualSize)))
        return result
    }
    
    
    public func get(drefs: [String], expectedSizes: [Int32]? = nil) throws -> [[Float]] {
        let expected = expectedSizes != nil ? expectedSizes! : Array(repeating: Int32(255), count: drefs.count)
        
        var valuesArray = [UnsafeMutablePointer<Float>?]()

        for size in expected {
            let values = UnsafeMutablePointer<Float>.allocate(capacity: Int(size))
            valuesArray.append(values)
        }
        
        let sizesArray = UnsafeMutablePointer<Int32>(mutating: expected)

//        var cDrefs = [UnsafePointer<Int8>]()
//        for dref in drefs {
//
//            let cs = (dref as NSString).utf8String
//            let cDref = UnsafeMutablePointer<Int8>(mutating: cs)!
//            cDrefs.append(cDref)
//        }
        
        var cargs = drefs.map { UnsafePointer<Int8>(strdup($0)) }
    
        if getDREFs(socket, &cargs, &valuesArray, UInt8(drefs.count), sizesArray) < 0 {
            throw XPError.network
        }
        
        var results = [[Float]]()
        let actualSizes = Array(UnsafeBufferPointer(start: sizesArray, count: drefs.count))
        for (index, values) in valuesArray.enumerated() {
            let actualSize = actualSizes[index]
            let result = Array(UnsafeBufferPointer(start: values, count: Int(actualSize)))
            results.append(result)
        }
        
        // todo see https://stackoverflow.com/questions/47911577/convert-swift-string-array-to-c-char?noredirect=1#comment83198421_47911577
        // for ptr in cargs { free(UnsafeMutablePointer(mutating: ptr)) }
        return results
    }
    
    public func withArrayOfCStrings<R>(_ args: [String], _ body: ([UnsafeMutablePointer<CChar>?]) -> R) -> R {
        var cStrings = args.map { strdup($0) }
        cStrings.append(nil)
        defer {
            cStrings.forEach { free($0) }
        }
        return body(cStrings)
    }
    
    public func get<P: Parser>(dref: String, parser: P) throws -> P.T {
        let result = try get(dref: dref)
        return try parser.parse(values: result)
    }
    
    public func send(dref: String, values: [Float]) {
        sendDREF(socket, dref.cString(using: .utf8), UnsafeMutablePointer<Float>(mutating: values), Int32(values.count))
    }
}

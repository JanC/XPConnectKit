//
//  Parsers.swift
//  XPConnectKit
//
//  Created by Jan Chaloupecky on 05.12.17.
//  Copyright © 2017 TequilaApps. All rights reserved.
//

import Foundation


public protocol Parser {
    
    associatedtype T
    
    var expectedSize: Int { get }
    
    func parse(values: [Float]) throws -> T
}

public struct FloatArrayPraser: Parser {
    
    public typealias T = [Float]
    
    public let expectedSize: Int
    
    public init(epxectedSize: Int = 50) {
        self.expectedSize = epxectedSize
    }
    
    public func parse(values: [Float]) throws -> [Float] {
        return values.map { $0 }
    }
}

public struct FloatPraser: Parser {
    
    public typealias T = Float
    
    public let expectedSize: Int
    
    public init() {
        self.expectedSize = 1
    }
    
    public func parse(values: [Float]) throws -> Float {
        return values.first!
    }
}

public struct IntParser: Parser {
    
    public typealias T = Int
    
    public let expectedSize: Int
    
    public init() {
        self.expectedSize = 1
    }
    
    public func parse(values: [Float]) throws -> Int {
        let result = values.first!
        if result > Float(Int.max) {
            fatalError("This should not happen")
        }
        return Int(result)
    }
}

public struct StringParser: Parser {
    public typealias T = String
    
    public let expectedSize: Int
    
    public init(epxectedSize: Int = 40) {
        self.expectedSize = epxectedSize
    }
    
    public func parse(values: [Float]) throws -> String {
        // map the Flats to chars
//        print("parsing String \(values)")
        let chars = try values.map { (float) -> CChar in
            
            let int = Int(float)
            if (int > Int8.max || int < Int8.min) {
                throw XPError.parsing("\(Int(float)) is not a valid character value")
            }
            return CChar(float)
            
        }
//        print("chars: \(chars)")
        let string: String = chars.withUnsafeBufferPointer { ptr in
            let s = String(cString: ptr.baseAddress!)
            return s
        }
//        print("string: \(string)")
        return string
    }
}

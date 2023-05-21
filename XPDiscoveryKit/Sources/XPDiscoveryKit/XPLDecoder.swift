//
//  XPLDecoder.swift
//  XPLKit
//
//  Created by Jan Chaloupecky on 27.11.17.
//  Copyright © 2017 TequilaApps. All rights reserved.
//

import Foundation

protocol Decodable {
    init(data: Data)
}

protocol Codable {
    // returns the UDP packet data
    func data() -> Data
}

struct XPLDecoder {
    static let commandLength = 5
    
    static func command(response: Data) -> XPLCommandType {
        // todo crash if packent is corruped e.g. 'BEC'
        let commandData = response.subdata(in: 0..<commandLength)
        
        guard let commandString = commandData.withUnsafeBytes({ (pointer: UnsafePointer<CChar>) -> String? in
            return String(cString: pointer)
        }) else {
            return .unknown
        }
        
        return XPLCommandType(rawValue: commandString) ?? .unknown
    }
    
    static func decode<T: Decodable>(response: Data, structLength: Int) -> T {
        return response.scanValue(start: commandLength, length: structLength)
    }
    
    static func decode(response: Data) -> XPLCommand {
        let commandType = command(response: response)
        // data without the command prefix
        let rawData = response.subdata(in: commandLength..<response.count)
        
        switch commandType {
        case .becn:
            return .becn(XPLBeacon(data: rawData))
        default:
            return .unknown("")
        }
    }
    
    // MARK: - Private
}

extension Data {
    func scanValue<T>(start: Int, length: Int) -> T {
        return self.subdata(in: start..<start + length).withUnsafeBytes { $0.pointee }
    }
    
    func object<T>(at index: Int) -> T {
        return self[index..<index + MemoryLayout<T>.size].withUnsafeBytes { $0.pointee }
    }
    
    func hexEncodedString() -> String {
        return map { String(format: "%02hhx", $0) }.joined()
    }
}

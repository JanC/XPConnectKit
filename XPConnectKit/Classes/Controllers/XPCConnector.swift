//
//  XPCConnector.swift
//  XPConnectKit
//
//  Created by Jan Chaloupecky on 13.12.17.
//  Copyright © 2017 TequilaApps. All rights reserved.
//

import Foundation

public protocol XPLConnectorDelegate {
    
    func connector(_ connector: XPLConnector, didReceive position: XPCPosition)
}

public class XPLConnector: NSObject {
    
    typealias DataRefCallback = (String) -> Void
    
    public var positionDelegate: XPLConnectorDelegate?
    // MARK: - Private
    let client: XPCClient
    
    var positionTimer: Timer?
    var drefTimers = [String: Timer]()
    var dataRefQueue = OperationQueue()
    
    public init(host: String) {
        client = XPCClient(host: host)
        dataRefQueue.maxConcurrentOperationCount = 1
    }
    

    public func start() {
        startRequestingPosition()
    }
    
    
    public func startUpdating<P: Parser>(dref: String, parser: P, interval: TimeInterval = 0.5 , callback: @escaping (P.T) -> Void) -> Bool {
        
        if drefTimers[dref] != nil {
            // already updating
            return false
        }
        
        let timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { (_) in
            let result = try! self.get(dref: dref, parser: parser)
            callback(result)
        }
        drefTimers[dref] = timer
        return true
    }
    
    public func stopUpdating(dref: String) {
        if let timer = drefTimers[dref] {
            timer.invalidate()
            drefTimers[dref] = nil
        }
    }
    
    public func get<P: Parser>(dref: String, parser: P) throws -> P.T {
        var result: P.T?
        var clientError: Error?
        dataRefQueue.addOperations([BlockOperation {
            do {
                result = try self.client.get(dref: dref, parser: parser)
            } catch {
                clientError = error
            }
            
        }], waitUntilFinished: true)
        
        if let clientError = clientError {
            throw clientError
        }
        return result!
    }
    
    func startRequestingPosition() {
        if (positionTimer != nil) {
            return
        }
        
        positionTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { (_) in
            if let position = try? self.client.getPosition() {
                print("position: \(position)")
                
                 self.positionDelegate?.connector(self, didReceive: position)
            }
        }
    }
}



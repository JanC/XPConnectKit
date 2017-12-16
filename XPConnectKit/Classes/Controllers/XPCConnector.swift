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
    
    public var positionDelegate: XPLConnectorDelegate?
    // MARK: - Private
    let client: XPCClient
    
    var positionTimer: Timer?
    var dataRefQueue = OperationQueue()
    
    public init(host: String) {
        client = XPCClient(host: host)
        dataRefQueue.maxConcurrentOperationCount = 1
    }
    

    public func start() {
        startRequestingPosition()
    }
    
    public func startRequestingDataRef() {
        //client.get(dref: <#T##String#>, parser: <#T##Parser#>)
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



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
    
    public init(host: String) {
        client = XPCClient(host: host)
    }
    

    public func start() {
        startRequestingPosition()
    }
    
    func startRequestingPosition() {
        if (positionTimer != nil){
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



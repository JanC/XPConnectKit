//
//  XPLKit.swift
//  XPLKit
//
//  Created by Jan Chaloupecky on 23.11.17.
//  Copyright © 2017 TequilaApps. All rights reserved.
//

import UIKit

public protocol XPDiscoveryDelegate: class {
    func discovery(_ discovery: XPDiscovery, didDiscoverNode node: XPLNode)
}
public class XPDiscovery: NSObject {
    
    // MARK: - Public properties
    
    public weak var delegate: XPDiscoveryDelegate?
    
    
    // MARK: - Private properties
    
    let client = XPLClient()
    var discoveredBeacons = [String: XPLNode]()
    
    //MARK: - Public Methods
    
    public override init() {
        super.init()
        client.delegate = self
    }
    
    public func start() throws {
        try client.setup()
    }
    
    // MARK: - Private Methods
    
    func handleBeacon(beacon: XPLBeacon, receivedFrom address: String) {
        if let _ = discoveredBeacons[address] {
            return
        }
        // received a new one, store it and call delegate
        let node = XPLNode(address: address, beacon: beacon)
        discoveredBeacons[address] = node
        
        delegate?.discovery(self, didDiscoverNode: node)
    }
}

extension XPDiscovery: XPLClientDelegate {
    
    func client(_ client: XPLClient, didFindBeacon beacon: XPLBeacon, atAddress address: String) {
        handleBeacon(beacon: beacon, receivedFrom: address)
    }
}

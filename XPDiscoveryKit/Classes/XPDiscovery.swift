//
//  XPLKit.swift
//  XPLKit
//
//  Created by Jan Chaloupecky on 23.11.17.
//  Copyright © 2017 TequilaApps. All rights reserved.
//

import UIKit

public protocol XPDiscoveryDelegate: AnyObject {

    /// Called when a new XPlaneConnect instasnce is found
    func discovery(_ discovery: XPDiscovery, didDiscoverNode node: XPLNode)

    func discovery(_ dicovery: XPDiscovery, didLostNode node: XPLNode)

}
public class XPDiscovery: NSObject {
    
    // MARK: - Public properties
    
    public weak var delegate: XPDiscoveryDelegate?

    // The queue on which will be called the delegate calls
    public var callbackQueue: OperationQueue = OperationQueue.main

    // If a received beacon is not received again within this timeout, the 'didLostNode' is called
    public let timeout: TimeInterval
    
    // MARK: - Private properties
    
    let client = XPLClient()

    private var discoveredBeacons = [String: XPLNode]()

    // for each address we keep a timer that will fire in case we don't receive a new beacon within the timout
    private var timeoutTimers = [String: Timer]()

    // MARK: - Public Methods
    
    public init(timeout: TimeInterval = 10) {
        self.timeout = timeout
        super.init()
        client.delegate = self
    }
    
    public func start() throws {
        try client.setup()
    }
    
    // MARK: - Private Methods
    
    private func handleBeacon(beacon: XPLBeacon, receivedFrom address: String) {
        if let node = discoveredBeacons[address] {
            handleExistingNode(node: node)
        } else {
            handleNewBeacon(beacon: beacon, receivedFrom: address)
        }
    }

    private func handleExistingNode(node: XPLNode) {
        let timer = timeoutTimers[node.address]
        timer?.invalidate()
        setupTimer(for: node)
    }

    private func handleTimeout(for node: XPLNode) {
        discoveredBeacons[node.address] = nil
        callbackQueue.addOperation { [weak self] in
            guard let self = self else { return }
            self.delegate?.discovery(self, didLostNode: node)
        }
    }

    private func setupTimer(for node: XPLNode) {
        DispatchQueue.main.async {
            //print("Setting up timeout for node \(node.address)")
            let timer = Timer.scheduledTimer(withTimeInterval: self.timeout, repeats: false) { [weak self] _ in
                self?.handleTimeout(for: node)
            }
            
            self.timeoutTimers[node.address] = timer
        }
    }

    private func handleNewBeacon(beacon: XPLBeacon, receivedFrom address: String) {
        // received a new one, store it, setup a timer and call delegate
        let node = XPLNode(address: address, beacon: beacon)
        discoveredBeacons[address] = node

        setupTimer(for: node)

        callbackQueue.addOperation { [weak self] in
            guard let self = self else { return }
            self.delegate?.discovery(self, didDiscoverNode: node)
        }
    }
}

extension XPDiscovery: XPLClientDelegate {
    
    func client(_ client: XPLClient, didFindBeacon beacon: XPLBeacon, atAddress address: String) {
        handleBeacon(beacon: beacon, receivedFrom: address)
    }
}

//
//  XPLClient.swift
//  XPLKit
//
//  Created by Jan Chaloupecky on 23.11.17.
//  Copyright © 2017 TequilaApps. All rights reserved.
//

import CocoaAsyncSocket
import Foundation

enum XPLClientError: Error {
    case failedToBind
    case failedToReceive
}

protocol XPLClientDelegate: AnyObject {

    func client(_ client: XPLClient, didFindBeacon beacon: XPLBeacon, atAddress address: String)
}

public class XPLClient: NSObject {

    weak var delegate: XPLClientDelegate?
    var socket: GCDAsyncUdpSocket?
    let queue = DispatchQueue(label: "net.tequilaapps.socket")

    override init() {
        super.init()
    }

    // MARK: - Public
    func setup() throws {
        
      
        let socket = GCDAsyncUdpSocket(delegate: self, delegateQueue: queue, socketQueue: queue)
        self.socket = socket
        do {
            
            try socket.bind(toPort: 49707)
            try socket.joinMulticastGroup("239.255.1.1")
        } catch {
            print("Failed to bind \(error)")
            throw XPLClientError.failedToBind
        }

        do {
            try socket.beginReceiving()
        } catch {
            print("Failed to receive \(error)")
            throw XPLClientError.failedToReceive
        }
        print("XPLClient started")
    }
    
    // MARK: - Private

    deinit {
        print("Client deinit")
        guard let socket = socket else { return }
        try? socket.leaveMulticastGroup("239.255.1.1")
        socket.close()
    }
}

// MARK: - GCDAsyncUdpSocketDelegate

extension XPLClient: GCDAsyncUdpSocketDelegate {

    public func udpSocket(_ sock: GCDAsyncUdpSocket, didConnectToAddress address: Data) {
        
    }

    public func udpSocket(_ sock: GCDAsyncUdpSocket, didNotConnect error: Error?) { }

    public func udpSocket(_ sock: GCDAsyncUdpSocket, didSendDataWithTag tag: Int) { }

    public func udpSocket(_ sock: GCDAsyncUdpSocket, didNotSendDataWithTag tag: Int, dueToError error: Error?) { }

    public func udpSocket(_ sock: GCDAsyncUdpSocket, didReceive data: Data, fromAddress address: Data, withFilterContext filterContext: Any?) {
        let command = XPLDecoder.decode(response: data)
        
        guard let address = GCDAsyncUdpSocket.host(fromAddress: address) else {
                print("Could not get address")
            return
        }
        switch command {
        case .becn(let beacon):
            delegate?.client(self, didFindBeacon: beacon, atAddress: address)
            break
        case .unknown(let command):
            print("Unknown command received: \(command) data:\(data.hexEncodedString())")
        }
    }

    public func udpSocketDidClose(_ sock: GCDAsyncUdpSocket, withError error: Error?) { }
}

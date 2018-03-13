//
//  XPCConnector.swift
//  XPConnectKit
//
//  Created by Jan Chaloupecky on 13.12.17.
//  Copyright © 2017 TequilaApps. All rights reserved.
//

import Foundation


public class XPLConnector: NSObject {
    
    public enum Result {
        case success([[Float]])
        case failure(Error)
    }


    // MARK: - Private
    let client: XPCClient
    
    var positionTimer: Timer?
    var drefTimers = [String: Timer]()

    // a queue that ensures that only 1 request at time is sent
    var synchronousQueue = OperationQueue()

    let backgroundQueue: OperationQueue = {
       let q = OperationQueue()
        q.name = "net.tequilaapps.xpconnector"
        return q
    }()
    
    public init(host: String) {
        client = XPCClient(host: host)
        synchronousQueue.maxConcurrentOperationCount = 1
    }

    // MARK: - Get Data Refs
    
    /*
        Gets a single dataref. The request are queued to avoid getting drefs in a wrong order
        See https://github.com/nasa/XPlaneConnect/issues/123
    */
    public func get<P: Parser>(dref: String, parser: P) throws -> P.T {
        var result: P.T?
        var clientError: Error?
        synchronousQueue.addOperations([BlockOperation {
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
    
    public func get(drefs: [String]) throws -> [[Float]] {
        var result = [[Float]]()
        var clientError: Error?
        synchronousQueue.addOperations([BlockOperation {
            do {
                result = try self.client.get(drefs: drefs)
            } catch {
                clientError = error
            }
        }], waitUntilFinished: true)
        
        if let clientError = clientError {
            throw clientError
        }
        return result
    }
    
    public func startRequesting(drefs: [String], interval: TimeInterval = 0.5, resultCallback: @escaping (Result) -> Void) -> Timer {
        return Timer.scheduledTimer(withTimeInterval: interval, repeats: true, block: { timer in

            if self.backgroundQueue.operations.count >= 1 {
                print("Skipping drefs request because one is already in progress. You might want to lower the update interval")
                return
            }
            
            self.backgroundQueue.addOperation() {
                do {
                    let result = try self.get(drefs: drefs)
                    resultCallback(Result.success(result))
                } catch {
                    resultCallback(Result.failure(error))
                }
            }
        })
    }

    /*
        Starts updating the give data ref and calls the callback regularly with the result value
    */
    public func startRequesting<P: Parser>(dref: String, parser: P, interval: TimeInterval = 1 , completionHandler: @escaping (P.T) -> Void) -> Bool {
        
        if drefTimers[dref] != nil {
            // already updating
            return false
        }
        
        let timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { (_) in
            if let result = try? self.get(dref: dref, parser: parser) {
                completionHandler(result)
            }
        }
        drefTimers[dref] = timer
        return true
    }

    /*
        Stops updating the given dref
        @param The data ref to stop
        @return false if the dataref was not updating
    */
    public func stopRequesting(dref: String) {
        if let timer = drefTimers[dref] {
            timer.invalidate()
            drefTimers[dref] = nil
        }
    }
    public func stopRequestingDataRefs() {
        for (dref, _) in drefTimers {
            stopRequesting(dref: dref)
        }
    }
    
    // MARK: - Send Data Ref
    
    public func send(dref: String, value: Float) {
        client.send(dref: dref, values: [value])
    }
    
    public func send(dref: String, values: [Float]) {
        client.send(dref: dref, values: values)
    }
    
    // MARK: - Position
    
    // Starts requesting the GETP and calls the completion handler
    public func startRequestingPosition(completionHandler: @escaping (XPCPosition) -> Void) {
        if (positionTimer != nil) {
            return
        }

        positionTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { (_) in
            if let position = try? self.client.getPosition() {
                print("position: \(position)")
                completionHandler(position)
            }
        }
    }

    /*
        Stops requesting the position
        @return false if the position was not updating
    */
    public func stopRequestingPosition() -> Bool {
        if(positionTimer == nil) {
            return false
        }
        positionTimer!.invalidate()
        positionTimer = nil
        return true
    }
}

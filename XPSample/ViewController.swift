//
//  ViewController.swift
//  XPSample
//
//  Created by Jan Chaloupecky on 04.12.17.
//  Copyright © 2017 TequilaApps. All rights reserved.
//

import UIKit
import XPConnectKit

class ViewController: UIViewController {

//    static let host = "192.168.1.197"
    static let host = "192.168.0.5"
    
    let client = XPCClient(host: ViewController.host)
    let connector = XPLConnector(host: ViewController.host)

    
    override func viewDidLoad() {
        super.viewDidLoad()
        connector.positionDelegate = self
    }

    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    @IBAction func sendAction() {
//        connector.start()
        
//        connect.get(dref: "sim/cockpit/radios/nav1_freq_hz")
        Timer.scheduledTimer(withTimeInterval: 0.001, repeats: true) { (_) in
//            if let position = try? self.client.getPosition() {
//                print("position: \(position)")
//            }
            self.requestDREFConnector()
        }

    }
    
    func requestDREF() {
        if let nav1 = try? client.get(dref: "sim/cockpit/radios/nav1_freq_hz", parser: FloatPraser()) {
            print("nav1: \(nav1)")
        }
        
        if let nav2 = try? client.get(dref: "sim/cockpit/radios/nav2_freq_hz", parser: FloatPraser()) {
            print("nav2: \(nav2)")
        }
        
//        if let tailNum = try? client.get(dref: "sim/aircraft/view/acf_tailnum", parser: StringParser()) {
//            print("tail num: \(tailNum)")
//        }
        
//        print("nav1: \(nav1 ?? "-" ) tail num: \(tailNum)")
    }
    
    func requestDREFConnector() {
        if let nav1 = try? connector.get(dref: "sim/cockpit/radios/nav1_freq_hz", parser: FloatPraser()) {
            print("nav1: \(nav1)")
        }
        
        if let nav2 = try? connector.get(dref: "sim/cockpit/radios/nav2_freq_hz", parser: FloatPraser()) {
            print("nav2: \(nav2)")
        }
        
//        if let tailNum = try? connector.get(dref: "sim/aircraft/view/acf_tailnum", parser: StringParser()) {
//            print("tail num: \(tailNum)")
//        }
    }
}

extension ViewController: XPLConnectorDelegate {
    func connector(_ connector: XPLConnector, didReceive position: XPCPosition) {
        print("\(#function): \(position)")
    }
}


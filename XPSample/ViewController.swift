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

    let connect = XPPlaneConnect(host: "192.168.1.197")
//    let connect = XPCPlaneConnect(host: "192.168.1.197")!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }

    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    @IBAction func sendAction() {
//        connect.get(dref: "sim/cockpit/radios/nav1_freq_hz")
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { (_) in
            self.requestDREF()
        }

    }
    
    func requestDREF() {
        if let nav1 = try? connect.get(dref: "sim/cockpit/radios/nav1_freq_hz", parser: FloatPraser()) {
            print("nav1: \(nav1)")
        }
        
        if let nav2 = try? connect.get(dref: "sim/cockpit/radios/nav2_freq_hz", parser: FloatPraser()) {
            print("nav2: \(nav2)")
        }
        
        if let tailNum = try? connect.get(dref: "sim/aircraft/view/acf_tailnum", parser: StringParser()) {
            print("tail num: \(tailNum)")
        }
    }
}


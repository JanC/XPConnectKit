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
    
    @IBOutlet var connectionLabel: UILabel!
    @IBOutlet var speedLabel: UILabel!
    @IBOutlet var verticalLabel: UILabel!
    @IBOutlet var altLabel: UILabel!
    
    @IBOutlet var com1Label: UILabel!
    @IBOutlet var com1LabelStby: UILabel!
    
    @IBOutlet var nav1Label: UILabel!
    @IBOutlet var nav1LabelStby: UILabel!
    
    let frequencyFormetter =  NumberFormatter()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        connector.positionDelegate = self
        
        frequencyFormetter.maximumFractionDigits = 2
        frequencyFormetter.minimumFractionDigits = 2
    }
    
    @IBAction func stopAction() {
        
    }
    @IBAction func startAction() {
//        connector.start()
        
        

//        Timer.scheduledTimer(withTimeInterval: 0.001, repeats: true) { (_) in
//            if let position = try? self.client.getPosition() {
//                print("position: \(position)")
//            }
//            self.requestDREFConnector()
        startUpdatingDrefs()
//        }
    }
    
    func requestDREF() {
        if let dataRef = try? client.get(dref: "sim/cockpit/radios/nav1_freq_hz", parser: FloatPraser()) {
            print("nav1: \(dataRef)")
            self.nav1Label.text = "\(frequencyFormetter.string(from: NSNumber(value: dataRef/100))!)"
        }
        
        if let dataRef = try? client.get(dref: "sim/cockpit/radios/nav1_stdby_freq_hz", parser: FloatPraser()) {
            print("nav2: \(dataRef)")
            self.nav1LabelStby.text = "\(frequencyFormetter.string(from: NSNumber(value: dataRef/100))!)"
        }
        
//        if let tailNum = try? client.get(dref: "sim/aircraft/view/acf_tailnum", parser: StringParser()) {
//            print("tail num: \(tailNum)")
//        }
        
//        print("nav1: \(nav1 ?? "-" ) tail num: \(tailNum)")
    }
    
    func startUpdatingDrefs() {
        
        let _ = connector.startUpdating(dref: "sim/cockpit/radios/nav1_freq_hz", parser: FloatPraser()) { dataRef in
            self.nav1Label.text = "\(self.frequencyFormetter.string(from: NSNumber(value: dataRef/100))!)"
        }
        
        let _ = connector.startUpdating(dref: "sim/cockpit/radios/nav1_stdby_freq_hz", parser: FloatPraser()) { dataRef in
            self.nav1LabelStby.text = "\(self.frequencyFormetter.string(from: NSNumber(value: dataRef/100))!)"
        }
        
        let _ = connector.startUpdating(dref: "sim/cockpit/radios/com1_freq_hz", parser: FloatPraser()) { dataRef in
            self.com1Label.text = "\(self.frequencyFormetter.string(from: NSNumber(value: dataRef/100))!)"
        }
        
        let _ = connector.startUpdating(dref: "sim/cockpit/radios/com1_stdby_freq_hz", parser: FloatPraser()) { dataRef in
            self.com1LabelStby.text = "\(self.frequencyFormetter.string(from: NSNumber(value: dataRef/100))!)"
        }
        
    }
    func requestDREFConnector() {
        
        
        if let dataRef = try? connector.get(dref: "sim/cockpit/radios/nav1_freq_hz", parser: FloatPraser()) {
            self.nav1Label.text = "\(frequencyFormetter.string(from: NSNumber(value: dataRef/100))!)"
        }
        
        if let dataRef = try? connector.get(dref: "sim/cockpit/radios/nav1_stdby_freq_hz", parser: FloatPraser()) {
            self.nav1LabelStby.text = "\(frequencyFormetter.string(from: NSNumber(value: dataRef/100))!)"
        }
        
        if let dataRef = try? connector.get(dref: "sim/cockpit/radios/com1_freq_hz", parser: FloatPraser()) {
            self.com1Label.text = "\(frequencyFormetter.string(from: NSNumber(value: dataRef/100))!)"
        }
        
        if let dataRef = try? connector.get(dref: "sim/cockpit/radios/com1_stdby_freq_hz", parser: FloatPraser()) {
            self.com1LabelStby.text = "\(frequencyFormetter.string(from: NSNumber(value: dataRef/100))!)"
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


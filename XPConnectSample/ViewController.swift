//
//  ViewController.swift
//  XPSample
//
//  Created by Jan Chaloupecky on 04.12.17.
//  Copyright © 2017 TequilaApps. All rights reserved.
//

import UIKit
import XPConnectKit
import XPDiscoveryKit
import CoreLocation

class ViewController: UIViewController {
    
//    static let host = "192.168.1.121"
        static let host = "192.168.1.197"
    //    static let host = "192.168.0.5"
    
    let client = XPCClient(host: ViewController.host)
    var connector: XPLConnector?
    
    lazy var discovery = XPDiscovery()
    
    @IBOutlet var connectionLabel: UILabel!
    @IBOutlet var speedLabel: UILabel!
    @IBOutlet var speedAirLabel: UILabel!
    @IBOutlet var verticalLabel: UILabel!
    @IBOutlet var altLabel: UILabel!
    @IBOutlet var altAglLabel: UILabel!
    @IBOutlet var hdgLabel: UILabel!
    
    @IBOutlet var com1Label: UILabel!
    @IBOutlet var com1LabelStby: UILabel!
    
    @IBOutlet var nav1Label: UILabel!
    @IBOutlet var nav1LabelStby: UILabel!
    
    @IBOutlet var tailnumLabel: UILabel!
    
    @IBOutlet var windSpeedLabel: UILabel!
    @IBOutlet var windDirectionLabel: UILabel!
    
    var host: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        discovery.delegate = self
        try? discovery.start()
        
        
        let connector = XPLConnector(host: "192.168.1.1")
        
        do {
            // com1 is an Int
            let com1 = try connector.get(dref: "sim/cockpit/radios/com1_freq_hz", parser: IntParser())
            print("com1: \(com1)")
            
            // result is a String
            let tailnum = try connector.get(dref: "sim/aircraft/view/acf_tailnum", parser: StringParser())
            print("tailnum: \(tailnum)")
            
        } catch {
            print("error: \(error)")
        }
    }
    
    @IBAction func stopAction() {
        connector?.stopRequestingDataRefs()
        
    }
    @IBAction func startAction() {
        
        print("Connecting to \(host ?? ViewController.host)")
        connector = XPLConnector(host: host ?? ViewController.host)
        
        startRequestingDataRefs()

    }
    
    func startRequestingDataRefs() {
        let radioDrefs = [
            "sim/cockpit/radios/com1_freq_hz",
            "sim/cockpit/radios/com1_stdby_freq_hz",
            "sim/cockpit/radios/nav1_freq_hz",
            "sim/cockpit/radios/nav1_stdby_freq_hz",
            
            "sim/flightmodel/position/vh_ind",
            "sim/flightmodel/position/indicated_airspeed",
            "sim/flightmodel/position/groundspeed",
            
            "sim/weather/wind_speed_kt",
            "sim/weather/wind_direction_degt",
            
            // Alt
            "sim/flightmodel/position/elevation",
            "sim/flightmodel/position/y_agl",
            "sim/flightmodel/position/mag_psi"
            ]
        
        let intParser = IntParser()
        let floatParser = FloatParser()
        connector?.startRequesting(drefs: radioDrefs) { (result) in
            switch result {
            case .success(let values):
                do {
                    var index = 0
                    self.com1Label.text = try intParser.parse(values: values[index]).formattedFrequency
                    index += 1
                    
                    self.com1LabelStby.text = try intParser.parse(values: values[index]).formattedFrequency
                    index += 1
                    
                    self.nav1Label.text = try intParser.parse(values: values[index]).formattedFrequency
                    index += 1
                    
                    self.nav1LabelStby.text = try intParser.parse(values: values[index]).formattedFrequency
                    index += 1
                    
                    self.verticalLabel.text = try CLLocationSpeed(floatParser.parse(values: values[index])).fpm.formattedSpeedFPM
                    index += 1
                    
                    self.speedAirLabel.text = try Double(floatParser.parse(values: values[index])).formattedSpeedKnots
                    index += 1
                    
                    self.speedLabel.text = try Double(floatParser.parse(values: values[index])).formattedSpeedKnots
                    index += 1
                    
                    self.windSpeedLabel.text = try Double(floatParser.parse(values: values[index])).formattedSpeedKnots
                    index += 1
                    
                    let direction = try IntParser().parse(values: values[index])
                    self.windDirectionLabel.text = "\(direction)°"
                    index += 1
                    
                    // ALT
                    self.altLabel.text = try Double(floatParser.parse(values: values[index])).feet.value.formattedAltitude
                    index += 1
                    
                    self.altAglLabel.text = try Double(floatParser.parse(values: values[index])).feet.value.formattedAltitude
                    index += 1
                    
                    let heading  = try Double(floatParser.parse(values: values[index])).formattedHeading
                    self.hdgLabel.text = heading
                    index += 1
                    
                } catch {
                    print("Could not parse dref: \(error)")
                }
            case .failure(let error):
                self.handle(error: error)
            }
        }
    }
    

    
    func handle(error: Error) {
        print("Error: \(error)")
        if case XPError.network = error {
            // stop polling here
            self.connector?.stopRequestingDataRefs()
            askYesNo(title: "Disconnected", question: "Reconnect?", yesAction: {
                self.startAction()
            })
        }
    }
}

extension ViewController: XPDiscoveryDelegate {
    func discovery(_ discovery: XPDiscovery, didDiscoverNode node: XPLNode) {
        print("Discovered XPlane: \(node.hostName) - \(node.beacon.versionNumber)")
        host = node.address
    }
}



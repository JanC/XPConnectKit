//
//  ViewController.swift
//  XPSample
//
//  Created by Jan Chaloupecky on 04.12.17.
//  Copyright © 2017 TequilaApps. All rights reserved.
//

import CoreLocation
import UIKit
import XPConnectKit
import XPDiscoveryKit

class ViewController: UIViewController {
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
    
    var host: String = "192.168.0.11"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        discovery.delegate = self
        do {
            try discovery.start()
        } catch {
            showAlert(title: "Could not start discovery", message: error.localizedDescription)
        }
    }
    
    @IBAction func stopAction() {
        connector?.stopRequestingDataRefs()
    }
    @IBAction func startAction() {
        print("Connecting to \(host)")
        connector = XPLConnector(host: host)
        
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
        connector?.startRequesting(drefs: radioDrefs, interval: 0.3) { result in
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
                    
                    self.speedLabel.text = try Double(floatParser.parse(values: values[index])).knots.value.formattedSpeedKnots
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
                    
                    let heading = try Double(floatParser.parse(values: values[index])).formattedHeading
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
    }
}

extension ViewController: XPDiscoveryDelegate {
    func discovery(_ discovery: XPDiscovery, didDiscoverNode node: XPLNode) {
        host = node.address
        let message = "Discovered XPlane version \(node.beacon.xplaneVersion) - \(node.beacon.xplaneConnectVersion): \(node.address):\(node.port)"
        print(message)
        host = node.address

        askYesNo(title: message, question: "Connect now?", yesAction: {
            self.startAction()
        })
    }

    func discovery(_ dicovery: XPDiscovery, didLostNode node: XPLNode) {
        print("Connection lost. No beacon received from \(node.address) after \(discovery.timeout)s")
        showAlert(title: "Connection lost", message: "No beacon received from \(node.address) after \(discovery.timeout)s")
    }
}

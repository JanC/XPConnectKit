//
//  ViewController.swift
//  XPSample
//
//  Created by Jan Chaloupecky on 04.12.17.
//  Copyright © 2017 TequilaApps. All rights reserved.
//

import UIKit
import XPConnectKit
import CoreLocation

class ViewController: UIViewController {
    
    static let host = "192.168.1.121"
    //    static let host = "192.168.1.197"
    //    static let host = "192.168.0.5"
    
    let client = XPCClient(host: ViewController.host)
    let connector = XPLConnector(host: ViewController.host)
    
    @IBOutlet var connectionLabel: UILabel!
    @IBOutlet var speedLabel: UILabel!
    @IBOutlet var speedAirLabel: UILabel!
    @IBOutlet var verticalLabel: UILabel!
    @IBOutlet var altLabel: UILabel!
    @IBOutlet var altAglLabel: UILabel!
    
    @IBOutlet var com1Label: UILabel!
    @IBOutlet var com1LabelStby: UILabel!
    
    @IBOutlet var nav1Label: UILabel!
    @IBOutlet var nav1LabelStby: UILabel!
    
    @IBOutlet var tailnumLabel: UILabel!
    
    @IBOutlet var windSpeedLabel: UILabel!
    @IBOutlet var windDirectionLabel: UILabel!
    
    var radioTimer: Timer?
    var speedTimer: Timer?
    var weatherTimer : Timer?
    var altTimer: Timer?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let client = XPCClient(host: "192.168.1.1")
        do {
            // com1 is an Int
            let com1 = try client.get(dref: "sim/cockpit/radios/com1_freq_hz", parser: IntParser())
            print("com1: \(com1)")
            
            // result is a String
            let tailnum = try client.get(dref: "sim/aircraft/view/acf_tailnum", parser: StringParser())
            print("tailnum: \(tailnum)")
            
        } catch {
            print("error: \(error)")
        }
        
    }
    
    @IBAction func stopAction() {
        connector.stopRequestingDataRefs()
        
        stopRequestingSpeed()
        stopRequestingRadios()
        stopRequestingWeather()
        stopRequestingAlt()
        
    }
    @IBAction func startAction() {
        startRequestingSpeed()
        startRequestingRadios()
        startRequestingWeather()
        startRequestingAlt()
    }
    
    func startRequestingRadios() {
        let radioDrefs = [
            "sim/cockpit/radios/com1_freq_hz",
            "sim/cockpit/radios/com1_stdby_freq_hz",
            "sim/cockpit/radios/nav1_freq_hz",
            "sim/cockpit/radios/nav1_stdby_freq_hz",
            ]
        
        let parser = IntParser()
        radioTimer = connector.startRequesting(drefs: radioDrefs) { (result) in
            switch result {
            case .success(let values):
                do {
                    var index = 0
                    self.com1Label.text = try parser.parse(values: values[index]).formattedFrequency
                    index += 1
                    
                    self.com1LabelStby.text = try parser.parse(values: values[index]).formattedFrequency
                    index += 1
                    
                    self.nav1Label.text = try parser.parse(values: values[index]).formattedFrequency
                    index += 1
                    
                    self.nav1LabelStby.text = try parser.parse(values: values[index]).formattedFrequency
                    index += 1
                } catch {
                    print("Could not parse dref: \(error)")
                }
            case .failure(let error):
                self.handle(error: error)
            }
        }
    }
    
    func stopRequestingRadios() {
        radioTimer?.invalidate()
        radioTimer = nil
    }
    
    func startRequestingSpeed() {
        let drefs = [
            "sim/flightmodel/position/vh_ind",
            "sim/flightmodel/position/indicated_airspeed",
            "sim/flightmodel/position/groundspeed"
        ]
        
        let parser = FloatParser()
        speedTimer = connector.startRequesting(drefs: drefs) { (result) in
            
            switch result {
            case .success(let values):
                do {
                    var index = 0
                    self.verticalLabel.text = try CLLocationSpeed(parser.parse(values: values[index])).fpm.formattedSpeedFPM
                    
                    index += 1
                    
                    self.speedAirLabel.text = try Double(parser.parse(values: values[index])).formattedSpeedKnots
                    index += 1
                    
                    self.speedLabel.text = try Double(parser.parse(values: values[index])).formattedSpeedKnots
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
        }
    }
    
    func stopRequestingSpeed() {
        speedTimer?.invalidate()
        speedTimer = nil
    }
    
    func startRequestingWeather() {
        let drefs = [
            "sim/weather/wind_speed_kt",
            "sim/weather/wind_direction_degt"
        ]
        
        let parser = FloatParser()
        weatherTimer = connector.startRequesting(drefs: drefs) { (result) in
            
            switch result {
            case .success(let values):
                do {
                    var index = 0
                    self.windSpeedLabel.text = try Double(parser.parse(values: values[index])).formattedSpeedKnots
                    
                    index += 1
                    
                    let direction = try IntParser().parse(values: values[index])
                    self.windDirectionLabel.text = "\(direction)°"
                    index += 1
                    
                } catch {
                    print("Could not parse dref: \(error)")
                }
            case .failure(let error):
                self.handle(error: error)
            }
        }
    }
    
    func stopRequestingWeather() {
        weatherTimer?.invalidate()
        weatherTimer = nil
    }
    
    func startRequestingAlt() {
        let drefs = [
            "sim/flightmodel/position/elevation",
            "sim/flightmodel/position/y_agl"
        ]
        
        let parser = FloatParser()
        altTimer = connector.startRequesting(drefs: drefs) { (result) in
            
            switch result {
            case .success(let values):
                do {
                    var index = 0
                    
                    self.altLabel.text = try Double(parser.parse(values: values[index])).feet.value.formattedAltitude
                    index += 1
                    
                    self.altAglLabel.text = try Double(parser.parse(values: values[index])).feet.value.formattedAltitude
                    index += 1
                    
                } catch {
                    print("Could not parse dref: \(error)")
                }
            case .failure(let error):
                self.handle(error: error)
            }
        }
    }
    
    func stopRequestingAlt() {
        altTimer?.invalidate()
        altTimer = nil
    }
}



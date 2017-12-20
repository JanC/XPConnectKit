//
//  ViewController.swift
//  XPSample
//
//  Created by Jan Chaloupecky on 04.12.17.
//  Copyright © 2017 TequilaApps. All rights reserved.
//

import UIKit
import XPConnectKit
import UnitKit
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

    }
    
    @IBAction func stopAction() {
        let _ = connector.stopRequestingPosition()
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

        
//        startUpdatingDrefs()
//
//        connector.startRequestingPosition { position in
//            self.altLabel.text = position.location.altitude.feet.value.formattedAltitude
//        }
//
//        connector.send(dref: "sim/cockpit/radios/nav1_freq_hz", value: 12345.00)
    }
    
    func startRequestingRadios() {
        let radioDrefs = [
            "sim/cockpit/radios/com1_freq_hz",
            "sim/cockpit/radios/com1_stdby_freq_hz",
            "sim/cockpit/radios/nav1_freq_hz",
            "sim/cockpit/radios/nav1_stdby_freq_hz",
            ]
        
        let parser = IntParser()
        radioTimer = connector.startRequesting(drefs: radioDrefs) { (values) in
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
        
        let parser = FloatPraser()
        speedTimer = connector.startRequesting(drefs: drefs) { (values) in
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
        
        let parser = FloatPraser()
        weatherTimer = connector.startRequesting(drefs: drefs) { (values) in
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
        
        let parser = FloatPraser()
        altTimer = connector.startRequesting(drefs: drefs) { (values) in
            do {
                var index = 0

                self.altLabel.text = try Double(parser.parse(values: values[index])).feet.value.formattedAltitude
                index += 1
                
                self.altAglLabel.text = try Double(parser.parse(values: values[index])).feet.value.formattedAltitude
                index += 1
                
            } catch {
                print("Could not parse dref: \(error)")
            }
        }
    }
    
    func stopRequestingAlt() {
        altTimer?.invalidate()
        altTimer = nil
    }

    
    func startUpdatingDrefs() {
        
//        let _ = connector.startRequesting(dref: "sim/cockpit/radios/nav1_freq_hz", parser: IntParser()) { dataRef in
//            self.nav1Label.text = dataRef.formattedFrequency
//        }
//
//        let _ = connector.startRequesting(dref: "sim/cockpit/radios/nav1_stdby_freq_hz", parser: IntParser()) { dataRef in
//            self.nav1LabelStby.text = dataRef.formattedFrequency
//        }
//
//        let _ = connector.startRequesting(dref: "sim/cockpit/radios/com1_freq_hz", parser: IntParser()) { dataRef in
//            self.com1Label.text = dataRef.formattedFrequency
//        }
//
//        let _ = connector.startRequesting(dref: "sim/cockpit/radios/com1_stdby_freq_hz", parser: IntParser()) { dataRef in
//            self.com1LabelStby.text = dataRef.formattedFrequency
//        }

//        let _ = connector.startRequesting(dref: "sim/flightmodel/position/vh_ind", parser: FloatPraser()) { dataRef in
//            self.verticalLabel.text = CLLocationSpeed(dataRef).fpm.formattedSpeedFPM
//        }



//        let _ = connector.startRequesting(dref: "sim/flightmodel/position/indicated_airspeed", parser: FloatPraser()) { dataRef in
//            self.speedAirLabel.text = Double(dataRef).formattedSpeedKnots
//         }

//        let _ = connector.startRequesting(dref: "sim/flightmodel/position/groundspeed", parser: FloatPraser()) { dataRef in
//            self.speedLabel.text = Double(dataRef).knots.value.formattedSpeedKnots
//        }

        let _ = connector.startRequesting(dref: "sim/flightmodel/position/y_agl", parser: FloatPraser()) { dataRef in
            self.altAglLabel.text = Double(dataRef).feet.value.formattedAltitude
        }
        
//        let _ = connector.startRequesting(dref: "sim/weather/wind_speed_kt", parser: FloatPraser()) { dataRef in
//            self.windSpeedLabel.text = Double(dataRef).knots.value.formattedSpeedKnots
//        }
//
//        let _ = connector.startRequesting(dref: "sim/weather/wind_direction_degt", parser: IntParser()) { dataRef in
//            self.windDirectionLabel.text = "\(dataRef) °"
//        }
        
        let _ = connector.startRequesting(dref: "sim/aircraft/view/acf_tailnum", parser: StringParser()) { dataRef in
            self.tailnumLabel.text = dataRef
        }
        
    }
}



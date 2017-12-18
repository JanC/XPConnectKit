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

//    static let host = "192.168.1.197"
    static let host = "192.168.0.5"
    
    let client = XPCClient(host: ViewController.host)
    let connector = XPLConnector(host: ViewController.host)
    
    @IBOutlet var connectionLabel: UILabel!
    @IBOutlet var speedLabel: UILabel!
    @IBOutlet var speedAirLabel: UILabel!
    @IBOutlet var verticalLabel: UILabel!
    @IBOutlet var altLabel: UILabel!
    
    @IBOutlet var com1Label: UILabel!
    @IBOutlet var com1LabelStby: UILabel!
    
    @IBOutlet var nav1Label: UILabel!
    @IBOutlet var nav1LabelStby: UILabel!
    
    @IBOutlet var tailnumLabel: UILabel!
    
    @IBOutlet var windSpeedLabel: UILabel!
    @IBOutlet var windDirectionLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func stopAction() {
        let _ = connector.stopRequestingPosition()
        connector.stopRequestingDataRefs()
        
    }
    @IBAction func startAction() {
        startUpdatingDrefs()
        
        connector.startRequestingPosition { position in
            self.altLabel.text = position.location.altitude.feet.value.formattedAltitude
        }
        
        connector.send(dref: "sim/cockpit/radios/nav1_freq_hz", value: 12345.00)
    }
    
    func startUpdatingDrefs() {
        
        let _ = connector.startRequesting(dref: "sim/cockpit/radios/nav1_freq_hz", parser: IntParser()) { dataRef in
            self.nav1Label.text = dataRef.formattedFrequency
        }

        let _ = connector.startRequesting(dref: "sim/cockpit/radios/nav1_stdby_freq_hz", parser: IntParser()) { dataRef in
            self.nav1LabelStby.text = dataRef.formattedFrequency
        }

        let _ = connector.startRequesting(dref: "sim/cockpit/radios/com1_freq_hz", parser: IntParser()) { dataRef in
            self.com1Label.text = dataRef.formattedFrequency
        }

        let _ = connector.startRequesting(dref: "sim/cockpit/radios/com1_stdby_freq_hz", parser: IntParser()) { dataRef in
            self.com1LabelStby.text = dataRef.formattedFrequency
        }

        let _ = connector.startRequesting(dref: "sim/flightmodel/position/vh_ind", parser: FloatPraser()) { dataRef in
            self.verticalLabel.text = CLLocationSpeed(dataRef).fpm.formattedSpeedFPM
        }
        
        let _ = connector.startRequesting(dref: "sim/aircraft/view/acf_tailnum", parser: StringParser()) { dataRef in
            self.tailnumLabel.text = dataRef
        }

        let _ = connector.startRequesting(dref: "sim/flightmodel/position/indicated_airspeed", parser: FloatPraser()) { dataRef in
            self.speedAirLabel.text = Double(dataRef).formattedSpeedKnots
         }
        
        let _ = connector.startRequesting(dref: "sim/flightmodel/position/groundspeed", parser: FloatPraser()) { dataRef in
            self.speedLabel.text = Double(dataRef).knots.value.formattedSpeedKnots
        }
        
        let _ = connector.startRequesting(dref: "sim/weather/wind_speed_kt", parser: FloatPraser()) { dataRef in
            self.windSpeedLabel.text = Double(dataRef).knots.value.formattedSpeedKnots
        }
        
        let _ = connector.startRequesting(dref: "sim/weather/wind_direction_degt", parser: IntParser()) { dataRef in
            self.windDirectionLabel.text = "\(dataRef) °"
        }
        
    }
}



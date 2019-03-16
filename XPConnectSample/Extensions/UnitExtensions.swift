//
//  UnitExtensions.swift
//  XPConnectSample
//
//  Created by Jan Chaloupecky on 13.03.18.
//  Copyright © 2018 TequilaApps. All rights reserved.
//


import CoreLocation
import Foundation


public extension CLLocationSpeed {
    
    /// Knots from meters per second
    public var knots: Measurement<UnitSpeed> {
        get {
            var measurement = Measurement(value: self, unit: UnitSpeed.metersPerSecond)
            measurement.convert(to: UnitSpeed.knots)
            return measurement
        }
    }
    
    /// feet per minutes from meters per second
    public var fpm: Double {
        var measurement = Measurement(value: self, unit: UnitLength.meters)
        measurement.convert(to: UnitLength.feet)
        let fpm = measurement.value * 60
        return fpm
    }
}

public extension CLLocationDistance {
    
    /// feet from meters
    public var feet: Measurement<UnitLength> {
        get {
            var measurement = Measurement(value: self, unit: UnitLength.meters)
            measurement.convert(to: UnitLength.feet)
            return measurement
        }
    }
}

//public extension UnitLength {
//
//    static let formatter: MeasurementFormatter = {
//        let f = MeasurementFormatter()
//        f.locale = Locale(identifier: "en_US")
//        f.unitOptions = .providedUnit
//        f.numberFormatter.maximumFractionDigits = 0
//        return f
//    }()
//
//    public var formattedAltitude: String {
//        get {
//            return UnitLength.formatter.string(from: self)
//        }
//    }
//}

public extension Int {
    
    static var formatter = NumberFormatter()
    
    /// Formats a radio frequency: 12700 -> "127.00"
    var formattedFrequency: String {
        Int.formatter.maximumFractionDigits = 2
        Int.formatter.minimumFractionDigits = 2
        Int.formatter.decimalSeparator = "."
        let number = Float(self) / 100
        return Int.formatter.string(from: number as NSNumber)!
    }
}


public extension Double {
    
    static let formatter: NumberFormatter = {
        let f = NumberFormatter()
        f.maximumFractionDigits = 0
        f.minimumFractionDigits = 0
        f.decimalSeparator = "."
        return f
    }()
    
    static let decimalFormatter: NumberFormatter = {
        let f = NumberFormatter()
        f.maximumFractionDigits = 2
        f.minimumFractionDigits = 2
        f.decimalSeparator = "."
        return f
    }()
    
    /// 127.1 -> 127.10
    var formattedFrequency: String {
        return String(format: "%0.2f", self)
    }
    
    /// Rounds and formats a fpm speed into string: 1500.1 -> "1500 fpm"
    var formattedSpeedFPM: String {
        return "\(Double.formatter.string(from: self as NSNumber)!) fpm"
    }
    
    // Rounded feet altitude 2568.19 -> "2568 ft"
    var formattedAltitude: String {
        return "\(Double.formatter.string(from: self as NSNumber)!) ft"
    }
    
    // Rounded feet distance 2568.19 -> "2568 ft"
    var formattedDistance: String {
        return "\(Double.formatter.string(from: self as NSNumber)!) ft"
    }
    
    // Rounded feet altitude 351.1 -> "350°M"
    var formattedHeading: String {
        return "\(Double.formatter.string(from: self as NSNumber)!)°"
    }
    
    var formattedSpeedKnots: String {
        return "\(Double.formatter.string(from: self as NSNumber)!) kts"
    }
    
    var formattedPressureInHg: String {
        return "\(Double.decimalFormatter.string(from: self as NSNumber)!) inHg"
    }
    
    var formattedPressureHectopascals: String {
        return "\(Double.formatter.string(from: self as NSNumber)!) hPa"
    }
    
    var feetToMeters: CLLocationDistance {
        var measurement = Measurement(value: self, unit: UnitLength.feet)
        measurement.convert(to: UnitLength.meters)
        return  measurement.value
    }
}

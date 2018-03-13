# XPConnectKit


[![Swift Version][swift-image]][swift-url]
[![License][license-image]][license-url]
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)![Platform](https://img.shields.io/cocoapods/p/LFAlertController.svg?style=flat)



`XPConnectKit` is a swift wrapper around the [XPlaneConnect](https://github.com/nasa/XPlaneConnect) client.


## Requirements

- iOS 11.0+
- Xcode 9.0

## Installation

<!-- #### CocoaPods 
You can use [CocoaPods](http://cocoapods.org/) to install `XPConnectKit ` by adding it to your `Podfile`:

```ruby
platform :ios, '11.0'
use_frameworks!
pod 'XPConnectKit'
``` -->

#### Carthage

Create a `Cartfile` that lists the framework and run `carthage update`. Follow the [instructions](https://github.com/Carthage/Carthage#if-youre-building-for-ios) to add `$(SRCROOT)/Carthage/Build/iOS/XPConnectKit.framework` to an iOS project.

```
github "JanC/XPConnectKit"
```
<!-- #### Manually
1. Download and drop ```XPConnectKit.swift``` in your project.  
2. Congratulations!   -->

## Usage example

The base class is the `XPLConnector` that you initialize with the ip or host name of the X-Plane running the XPlaneConnect server:

```swift
let connector = XPLConnector(host: "192.168.1.10")
```


### Single DREFs

To get a signle data ref, call the `connector.get(dref:"...")` method. To facilitate the parsing into expected types, you have to supply a `Parser` that will parse the float array into the type you expect:

```swift

let connector = connector(host: "192.168.1.10")

do {
    // The com1_freq_hz values is an Int e.g. 11800 so we pass IntParser
    let com1 = try connector.get(dref: "sim/cockpit/radios/com1_freq_hz", parser: IntParser())
    print("com1: \(com1)")
    
    // The acf_tailnum values is an String so we pass StringParser
    let tailnum = try connector.get(dref: "sim/aircraft/view/acf_tailnum", parser: StringParser())
    print("tailnum: \(tailnum)")
    
} catch {
    print("error: \(error)")
}
```

### Polling multiple DREF
Work in progress

You can use the `XPLConnector` to poll regurarly for a set of data refs. The closure with the result values will be called regurarly and result is a two dimentional array of Floats. You can use again a `Parser` to get the expected value:

```swift
let connector = XPLConnector(host: "192.168.1.10")

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
```



## Contribute

We would love you for the contribution to **XPConnectKit**, check the ``LICENSE`` file for more info.

## Meta

Jan Chaloupecky – [@TexTwil](https://twitter.com/TexTwil) 

Distributed under the XYZ license. See ``LICENSE`` for more information.


[swift-image]:https://img.shields.io/badge/swift-4.0-orange.svg
[swift-url]: https://swift.org/
[license-image]: https://img.shields.io/badge/License-MIT-blue.svg
[license-url]: LICENSE
[travis-image]: https://img.shields.io/travis/dbader/node-datadog-metrics/master.svg?style=flat-square
[travis-url]: https://travis-ci.org/dbader/node-datadog-metrics
[codebeat-image]: https://codebeat.co/badges/c19b47ea-2f9d-45df-8458-b2d952fe9dad
[codebeat-url]: https://codebeat.co/projects/github-com-vsouza-awesomeios-com
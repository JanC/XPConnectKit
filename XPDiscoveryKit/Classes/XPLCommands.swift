//
//  XPLCommands.swift
//  XPLKit
//
//  Created by Jan Chaloupecky on 27.11.17.
//  Copyright © 2017 TequilaApps. All rights reserved.
//

import Foundation

enum XPLCommand {
    case becn(XPLBeacon)
    case unknown(String)
}

enum XPLCommandType: String {
    case rpos = "RPOS4"
    case becn = "BECN"
    case rref = "RREF," // yes the RREF contains a ,
    case unknown
}

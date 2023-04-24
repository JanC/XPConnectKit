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
    case becn = "BECN"
    case unknown
}

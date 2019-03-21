//
//  Log.swift
//  AppVerifyDemo
//
//  Created by Plivo on 7/3/18.
//  Copyright © 2018 Plivo. All rights reserved.
//

import Foundation
import os.log

struct Log {
    static var general = OSLog(subsystem: "com.Plivo.AppVerifyDemo", category: "general")
    static var error = OSLog(subsystem: "com.Plivo.AppVerifyDemo", category: "error")
}

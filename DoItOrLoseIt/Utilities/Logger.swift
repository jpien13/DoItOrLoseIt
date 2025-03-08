//
//  logger.swift.swift
//  DoItOrLoseIt
//
//  Created by Jason Pien on 3/8/25.
//
// https://www.avanderlee.com/debugging/oslog-unified-logging/
//
//

import os.log
import Foundation

extension OSLog {
    /// Using your bundle identifier is a great way to ensure a unique identifier.
    private static var subsystem = Bundle.main.bundleIdentifier!
    
    static let app = OSLog(subsystem: subsystem, category: "App")
    static let location = OSLog(subsystem: subsystem, category: "Location")
    static let data = OSLog(subsystem: subsystem, category: "Data")
    static let tasks = OSLog(subsystem: subsystem, category: "Tasks")
    static let background = OSLog(subsystem: subsystem, category: "Background")
    
}

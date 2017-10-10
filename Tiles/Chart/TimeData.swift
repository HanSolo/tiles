//
//  TimeData.swift
//  Tiles
//
//  Created by Gerrit Grunwald on 09.10.17.
//  Copyright © 2017 Gerrit Grunwald. All rights reserved.
//

import UIKit

class TimeData: ChartData {
    
    convenience init(value: CGFloat) {
        self.init()
        self.value     = value
        self.timestamp = Date()
    }
    convenience init(value: CGFloat, timestamp: Date) {
        self.init()
        self.value     = value
        self.timestamp = timestamp
    }
    
    func toString() -> String {
        return "{\n" +
        "  \"timestamp\":\(timestamp.timeIntervalSince1970),\n" +
        "  \"value\":\(value)\n" +
        "}"
    }
}

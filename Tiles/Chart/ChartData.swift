//
//  ChartData.swift
//  Tiles
//
//  Created by Gerrit Grunwald on 02.10.17.
//  Copyright © 2017 Gerrit Grunwald. All rights reserved.
//

import UIKit

class ChartData {
    var eventBus            = EventBus()
    var name      : String  { didSet { eventBus.fireEvent(eventName: Helper.UPDATE, information: self) } }
    var color     : UIColor { didSet { eventBus.fireEvent(eventName: Helper.UPDATE, information: self) } }
    var timestamp : Date    { didSet { eventBus.fireEvent(eventName: Helper.UPDATE, information: self) } }
    var value     : CGFloat { didSet { self.oldValue = oldValue; eventBus.fireEvent(eventName: Helper.UPDATE, information: self) } }
    var oldValue  : CGFloat
    
    
    convenience init() {
        self.init(name: "", color: Helper.BLUE, timestamp: Date(), value: 0.0)
    }
    convenience init(value: CGFloat) {
        self.init(name: "", color: Helper.BLUE, timestamp: Date(), value: value)
    }
    convenience init(value: CGFloat, timestamp: Date) {
        self.init(name: "", color: Helper.BLUE, timestamp: timestamp, value: value)
    }
    convenience init(name: String, value: CGFloat) {
        self.init(name: name, color: Helper.BLUE, timestamp: Date(), value: value)
    }
    convenience init(name: String, timestamp: Date, value: CGFloat) {
        self.init(name: name, color: Helper.BLUE, timestamp: timestamp, value: value)
    }
    convenience init(name: String, color: UIColor, value: CGFloat) {
        self.init(name: name, color: color, timestamp: Date(), value: value)
    }
    init(name: String, color: UIColor, timestamp: Date, value: CGFloat) {
        self.name      = name
        self.color     = color
        self.timestamp = timestamp
        self.value     = value
        self.oldValue  = value
    }
}

//
//  TimeSection.swift
//  Tiles
//
//  Created by Gerrit Grunwald on 06.10.17.
//  Copyright © 2017 Gerrit Grunwald. All rights reserved.
//

import UIKit

class TimeSection {
    var start          : Date
    var stop           : Date
    var text           : String
    var icon           : UIImage
    var color          : UIColor
    var highlightColor : UIColor
    var textColor      : UIColor
    var checkedValue   : Date
    var active         : Bool
    var days           : Set<Int>
    var listeners      : [TimeSectionEventListener] = []
    
    
    // ******************** Constructors *************
    convenience init() {
        self.init(start: Date(), stop: Date(), text: "", icon: UIImage(), color: UIColor.clear, highlightColor: UIColor.clear, textColor: UIColor.clear, active: true, days: 0,1,2,3,4,5,6,7)
    }
    convenience init(start: Date, stop: Date) {
        self.init(start: start, stop: stop, text: "", icon: UIImage(), color: UIColor.clear, highlightColor: UIColor.clear, textColor: UIColor.clear, active: true, days: 0,1,2,3,4,5,6,7)
    }
    convenience init(start: Date, stop: Date, color: UIColor) {
        self.init(start: start, stop: stop, text: "", icon: UIImage(), color: color, highlightColor: UIColor.clear, textColor: UIColor.clear, active: true, days: 0,1,2,3,4,5,6,7)
    }
    convenience init(start: Date, stop: Date, color: UIColor, highlightColor: UIColor) {
        self.init(start: start, stop: stop, text: "", icon: UIImage(), color: color, highlightColor: highlightColor, textColor: UIColor.clear, active: true, days: 0,1,2,3,4,5,6,7)
    }
    convenience init(start: Date, stop: Date, color: UIColor, highlightColor: UIColor, days: Int...) {
        self.init(start: start, stop: stop, text: "", icon: UIImage(), color: color, highlightColor: highlightColor, textColor: UIColor.clear, active: true, days: days)
    }
    convenience init(start: Date, stop: Date, icon: UIImage, color: UIColor) {
        self.init(start: start, stop: stop, text: "", icon: icon, color: color, highlightColor: UIColor.clear, textColor: UIColor.clear, active: true, days: 0,1,2,3,4,5,6,7)
    }
    convenience init(start: Date, stop: Date, text: String, color: UIColor) {
        self.init(start: start, stop: stop, text: text, icon: UIImage(), color: color, highlightColor: UIColor.clear, textColor: UIColor.clear, active: true, days: 0,1,2,3,4,5,6,7)
    }
    convenience init(start: Date, stop: Date, text: String, color: UIColor, textColor: UIColor) {
        self.init(start: start, stop: stop, text: text, icon: UIImage(), color: color, highlightColor: UIColor.clear, textColor: textColor, active: true, days: 0,1,2,3,4,5,6,7)
    }
    convenience init(start: Date, stop: Date, text: String, icon: UIImage, color: UIColor, textColor: UIColor) {
        self.init(start: start, stop: stop, text: text, icon: icon, color: color, highlightColor: UIColor.clear, textColor: textColor, active: true, days: 0,1,2,3,4,5,6,7)
    }
    convenience init(start: Date, stop: Date, text: String, icon: UIImage, color: UIColor, highlightColor: UIColor, textColor: UIColor, active: Bool, days: [Int]) {
        self.init(start: start, stop: stop, text: text, icon: icon, color: color, highlightColor: highlightColor, textColor: textColor, active: active, days: days)
    }
    init(start: Date, stop: Date, text: String, icon: UIImage, color: UIColor, highlightColor: UIColor, textColor: UIColor, active: Bool, days: Int...) {
        self.start          = start
        self.stop           = stop
        self.text           = text
        self.icon           = icon
        self.color          = color
        self.highlightColor = highlightColor
        self.textColor      = textColor
        self.checkedValue   = Date.init(timeIntervalSince1970: TimeInterval(0))
        self.active         = active
        self.days           = Set(days)
    }
    
    
    // ******************** Methods ********************
    func contains(value : Date) -> Bool {
        return value >= start && value <= stop
    }
    
    func checkForTime(value : Date) {
        let wasInSection = contains(value: checkedValue)
        let isInSection  = contains(value: value)
        if (!wasInSection && isInSection) {
            fireTimeSectionEvent(event: TimeSectionEvent(src: self, type: TimeSectionEventType.ENTERED))
        } else if (wasInSection && !isInSection) {
            fireTimeSectionEvent(event: TimeSectionEvent(src: self, type: TimeSectionEventType.LEFT))
        }
        checkedValue = value
    }
    
    
    // ******************** Event Handling *************
    func addTimeSectionEventListener(listener: TimeSectionEventListener) {
        if (!listeners.isEmpty) {
            for i in 0...listeners.count { if (listeners[i] === listener) { return } }
        }
        listeners.append(listener)
    }
    func removeTimeSectionEventListener(listener: TimeSectionEventListener) {
        for i in 0...listeners.count {
            if listeners[i] === listener {
                listeners.remove(at: i)
                return
            }
        }
    }
    func fireTimeSectionEvent(event : TimeSectionEvent) {
        listeners.forEach { listener in listener.onTimeSectionEvent(event: event) }
    }
}

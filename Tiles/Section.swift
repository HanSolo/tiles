//
//  Section.swift
//  Tiles
//
//  Created by Gerrit Grunwald on 04.10.17.
//  Copyright © 2017 Gerrit Grunwald. All rights reserved.
//

import UIKit

class Section {
    let ENTERED_EVENT = SectionEvent(type: SectionEventType.ENTERED)
    let LEFT_EVENT    = SectionEvent(type: SectionEventType.LEFT)
    let UPDATE_EVENT  = SectionEvent(type: SectionEventType.UPDATE)
    var start          : CGFloat { didSet { fireSectionEvent(event: UPDATE_EVENT) }}
    var stop           : CGFloat { didSet { fireSectionEvent(event: UPDATE_EVENT) }}
    var text           : String  { didSet { fireSectionEvent(event: UPDATE_EVENT) }}
    var icon           : UIImage { didSet { fireSectionEvent(event: UPDATE_EVENT) }}
    var color          : UIColor { didSet { fireSectionEvent(event: UPDATE_EVENT) }}
    var highlightColor : UIColor { didSet { fireSectionEvent(event: UPDATE_EVENT) }}
    var textColor      : UIColor { didSet { fireSectionEvent(event: UPDATE_EVENT) }}
    var checkedValue   : CGFloat
    var listeners      : [SectionEventListener] = []
    
    
    // ******************** Constructors *************
    convenience init() {
        self.init(start: -1, stop: -1, text: "", icon: UIImage(), color: UIColor.clear, highlightColor: UIColor.clear, textColor: UIColor.clear)
    }
    convenience init(start: CGFloat, stop: CGFloat) {
        self.init(start:start, stop:stop, text:"", icon:UIImage(), color: UIColor.clear, highlightColor: UIColor.clear, textColor: UIColor.clear)
    }
    convenience init(start: CGFloat, stop: CGFloat, color: UIColor) {
        self.init(start:start, stop:stop, text:"", icon:UIImage(), color:color, highlightColor:color, textColor:UIColor.clear)
    }
    convenience init(start:CGFloat, stop:CGFloat, color:UIColor, highlightColor: UIColor) {
        self.init(start:start, stop:stop, text:"", icon:UIImage(), color:color, highlightColor:highlightColor, textColor:UIColor.clear)
    }
    convenience init(start: CGFloat, stop: CGFloat, icon: UIImage, color: UIColor) {
        self.init(start:start, stop:stop, text:"", icon:icon, color:color, highlightColor:color, textColor: Helper.FGD_COLOR)
    }
    convenience init(start: CGFloat, stop: CGFloat, text: String, color: UIColor) {
        self.init(start:start, stop:stop, text:text, icon:UIImage(), color:color, highlightColor:color, textColor:Helper.FGD_COLOR)
    }
    convenience init(start: CGFloat, stop: CGFloat, text: String, color: UIColor, textColor: UIColor) {
        self.init(start:start, stop:stop, text:text, icon:UIImage(), color:color, highlightColor:color, textColor:textColor)
    }
    convenience init (start : CGFloat, stop : CGFloat, text : String, icon : UIImage, color : UIColor, textColor : UIColor) {
        self.init(start:start, stop:stop, text:text, icon:icon, color:color, highlightColor:color, textColor:textColor)
    }
    init(start : CGFloat, stop : CGFloat, text : String, icon : UIImage, color : UIColor, highlightColor : UIColor, textColor : UIColor) {
        self.start          = start
        self.stop           = stop
        self.text           = text
        self.icon           = icon
        self.color          = color
        self.highlightColor = highlightColor
        self.textColor      = textColor
        self.checkedValue   = -CGFloat.greatestFiniteMagnitude
    }
    
    
    // ******************** Methods ********************
    func contains(value : CGFloat) -> Bool {
        return value >= start && value <= stop
    }
    
    func checkForValue(value : CGFloat) {
        let wasInSection = contains(value: checkedValue)
        let isInSection  = contains(value: value)
        if (!wasInSection && isInSection) {
            fireSectionEvent(event: ENTERED_EVENT)
        } else if (wasInSection && !isInSection) {
            fireSectionEvent(event: LEFT_EVENT)
        }
        checkedValue = value
    }
    
    
    // ******************** Event Handling *************
    func addSectionEventListener(listener: SectionEventListener) {
        if (!listeners.isEmpty) {
            for i in 0...listeners.count { if (listeners[i] === listener) { return } }
        }
        listeners.append(listener)
    }
    func removeSectionEventListener(listener: SectionEventListener) {
        for i in 0...listeners.count {
            if listeners[i] === listener {
                listeners.remove(at: i)
                return
            }
        }
    }
    func fireSectionEvent(event : SectionEvent) {
        listeners.forEach { listener in listener.onSectionEvent(event: event) }
    }
}

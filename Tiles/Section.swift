//
//  Section.swift
//  Tiles
//
//  Created by Gerrit Grunwald on 04.10.17.
//  Copyright © 2017 Gerrit Grunwald. All rights reserved.
//

import UIKit

class Section {
    var start          : CGFloat { didSet { fireSectionEvent(event: SectionEvent(src: self, type: SectionEventType.UPDATE)) }}
    var stop           : CGFloat { didSet { fireSectionEvent(event: SectionEvent(src: self, type: SectionEventType.UPDATE)) }}
    var text           : String  { didSet { fireSectionEvent(event: SectionEvent(src: self, type: SectionEventType.UPDATE)) }}
    var icon           : UIImage { didSet { fireSectionEvent(event: SectionEvent(src: self, type: SectionEventType.UPDATE)) }}
    var color          : UIColor { didSet { fireSectionEvent(event: SectionEvent(src: self, type: SectionEventType.UPDATE)) }}
    var highlightColor : UIColor { didSet { fireSectionEvent(event: SectionEvent(src: self, type: SectionEventType.UPDATE)) }}
    var textColor      : UIColor { didSet { fireSectionEvent(event: SectionEvent(src: self, type: SectionEventType.UPDATE)) }}
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
            fireSectionEvent(event: SectionEvent(src: self, type: SectionEventType.ENTERED))
        } else if (wasInSection && !isInSection) {
            fireSectionEvent(event: SectionEvent(src: self, type: SectionEventType.LEFT))
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

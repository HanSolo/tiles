//
//  ClockSkin.swift
//  Tiles
//
//  Created by Gerrit Grunwald on 04.10.17.
//  Copyright © 2017 Gerrit Grunwald. All rights reserved.
//

import UIKit

class ClockSkin: Skin {
    let timeLabel     = UILabel()
    let dateLabel     = UILabel()
    let dayLabel      = UILabel()
    var timer         = Timer()
    let timeFormatter = DateFormatter()
    let dateFormatter = DateFormatter()
    let dayFormatter  = DateFormatter()
    
    
    // ******************** Constructors ********************
    override init() {
        super.init()
    }
    override init(layer: Any) {
        super.init(layer: layer)
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    // ******************** Methods ********************
    override func update(cmd: String) {
        if (cmd == Helper.INIT) {
            control!.addSubview(timeLabel)
            control!.addSubview(dateLabel)
            control!.addSubview(dayLabel)
            
            timeFormatter.dateFormat = "HH:mm"
            dateFormatter.dateFormat = "dd MMM YYYY"
            dayFormatter.dateFormat  = "EEEE"
            
            timer = Timer.scheduledTimer(timeInterval: 1.0,
                                             target  : self,
                                             selector: #selector(tick),
                                             userInfo: nil,
                                             repeats : true)
        } else if (cmd == Helper.REDRAW) {
            setNeedsDisplay()
        }
    }
    override func update<T>(prop: String, value: T) {
        if (prop == "value") {
            
        }
    }
    
    override func layoutSublayers() {
        super.layoutSublayers()
        
    }
    
    
    @objc func tick() {        
        let now = Date()
        timeLabel.text = timeFormatter.string(from: now)
        dateLabel.text = dateFormatter.string(from: now)
        dayLabel.text  = dayFormatter.string(from: now)
    }
    
    
    // ******************** Redraw ********************
    override func draw(in ctx: CGContext) {
        super.draw(in: ctx)
        UIGraphicsPushContext(ctx)
        if let ctrl = control {
            width   = self.frame.width
            height  = self.frame.height
            size    = width < height ? width : height
            centerX = width * 0.5
            centerY = height * 0.5
            
            // Background
            let path = UIBezierPath(roundedRect: bounds, cornerRadius: size * 0.025)
            ctx.setFillColor(ctrl.bkgColor.cgColor)
            ctx.addPath(path.cgPath)
            ctx.fillPath()
            
            let smallFont  = UIFont.init(name: "Lato-Regular", size: size * 0.06)
            
            // Tile Title
            drawText(label   : ctrl.titleLabel,
                     font    : smallFont!,
                     text    : ctrl.title,
                     frame   : CGRect(x: size * 0.05, y: size * 0.05, width: width - size * 0.1, height: height * 0.08),
                     fgdColor: ctrl.fgdColor,
                     bkgColor: ctrl.bkgColor,
                     radius  : 0,
                     align   : .left)
            
            // Tile Text
            if (ctrl.textVisible) {
                drawText(label   : ctrl.textLabel,
                         font    : smallFont!,
                         text    : ctrl.text,
                         frame   : CGRect(x: size * 0.05, y: size * 0.89, width: width - size * 0.1, height: size * 0.08),
                         fgdColor: ctrl.fgdColor,
                         bkgColor: ctrl.bkgColor,
                         radius  : 0,
                         align   : .left)
            } else {
                ctrl.textLabel.textColor = UIColor.clear
            }
            
            let timeFont  = UIFont.init(name: "Lato-Regular", size: size * 0.3)
            let dateFont  = UIFont.init(name: "Lato-Regular", size: size * 0.1)
            let now       = Date()
            
            // Time Text
            drawText(label   : timeLabel,
                     font    : timeFont!,
                     text    : timeFormatter.string(from: now),
                     frame   : CGRect(x: 0.0, y: height * 0.18, width: width, height: height * 0.4),
                     fgdColor: ctrl.fgdColor,
                     bkgColor: ctrl.bkgColor.darker(by: 7)!,
                     radius  : 0,
                     align   : .center)
            
            // Date Text
            drawText(label   : dateLabel,
                     font    : dateFont!,
                     text    : dateFormatter.string(from: now),
                     frame   : CGRect(x: size * 0.05, y: height - size * 0.275, width: width - size * 0.1, height: height * 0.12),
                     fgdColor: ctrl.fgdColor,
                     bkgColor: ctrl.bkgColor,
                     radius  : 0,
                     align   : .left)
            
            // Day Text
            drawText(label   : dayLabel,
                     font    : dateFont!,
                     text    : dayFormatter.string(from: now),
                     frame   : CGRect(x: size * 0.05, y: height - size * 0.4, width: width - size * 0.1, height: height * 0.12),
                     fgdColor: ctrl.fgdColor,
                     bkgColor: ctrl.bkgColor,
                     radius  : 0,
                     align   : .left)
        }
        UIGraphicsPopContext()
    }
}


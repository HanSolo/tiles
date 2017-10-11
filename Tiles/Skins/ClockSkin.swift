//
//  ClockSkin.swift
//  Tiles
//
//  Created by Gerrit Grunwald on 04.10.17.
//  Copyright © 2017 Gerrit Grunwald. All rights reserved.
//

import UIKit

class ClockSkin: Skin {
    private let timeLabel     = UILabel()
    private let dateLabel     = UILabel()
    private let dayLabel      = UILabel()
    private var timer         = Timer()
    private let timeFormatter = DateFormatter()
    private let dateFormatter = DateFormatter()
    private let dayFormatter  = DateFormatter()
    
    
    // ******************** Constructors **************
    override init() {
        super.init()
    }
    override init(layer: Any) {
        super.init(layer: layer)
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    // ******************** Methods *******************
    override func update(cmd: String) {
        guard let tile = control else { return }
        
        if (cmd == Helper.INIT) {
            tile.addSubview(timeLabel)
            tile.addSubview(dateLabel)
            tile.addSubview(dayLabel)
            
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
    
    
    // ******************** Methods *******************
    @objc func tick() {        
        let now = Date()
        timeLabel.text = timeFormatter.string(from: now)
        dateLabel.text = dateFormatter.string(from: now)
        dayLabel.text  = dayFormatter.string(from: now)
    }
    
    
    // ******************** Redraw ********************
    override func draw(in ctx: CGContext) {
        super.draw(in: ctx)
        guard let tile = control else { return }
        
        UIGraphicsPushContext(ctx)
        
        width   = self.frame.width
        height  = self.frame.height
        size    = width < height ? width : height
        centerX = width * 0.5
        centerY = height * 0.5
        
        // Background
        let path = UIBezierPath(roundedRect: bounds, cornerRadius: size * 0.025)
        ctx.setFillColor(tile.bkgColor.cgColor)
        ctx.addPath(path.cgPath)
        ctx.fillPath()
        
        let smallFont  = UIFont.init(name: "Lato-Regular", size: size * 0.06)
        
        // Tile Title
        drawText(label   : tile.titleLabel,
                 font    : smallFont!,
                 text    : tile.title,
                 frame   : CGRect(x: size * 0.05, y: size * 0.05, width: width - size * 0.1, height: height * 0.08),
                 fgdColor: tile.fgdColor,
                 bkgColor: tile.bkgColor,
                 radius  : 0,
                 align   : tile.titleAlignment)
        
        // Tile Text
        if (tile.textVisible) {
            drawText(label   : tile.textLabel,
                     font    : smallFont!,
                     text    : tile.text,
                     frame   : CGRect(x: size * 0.05, y: height - size * 0.11, width: width - size * 0.1, height: size * 0.08),
                     fgdColor: tile.fgdColor,
                     bkgColor: tile.bkgColor,
                     radius  : 0,
                     align   : tile.textAlignment)
        } else {
            tile.textLabel.textColor = UIColor.clear
        }
        
        let timeFont  = UIFont.init(name: "Lato-Regular", size: size * 0.3)
        let dateFont  = UIFont.init(name: "Lato-Regular", size: size * 0.1)
        let now       = Date()
        
        // Time Text
        drawText(label   : timeLabel,
                 font    : timeFont!,
                 text    : timeFormatter.string(from: now),
                 frame   : CGRect(x: 0.0, y: height * 0.18, width: width, height: height * 0.4),
                 fgdColor: tile.fgdColor,
                 bkgColor: tile.bkgColor.darker(by: 7)!,
                 radius  : 0,
                 align   : .center)
        
        // Date Text
        drawText(label   : dateLabel,
                 font    : dateFont!,
                 text    : dateFormatter.string(from: now),
                 frame   : CGRect(x: size * 0.05, y: height - size * 0.275, width: width - size * 0.1, height: height * 0.12),
                 fgdColor: tile.fgdColor,
                 bkgColor: tile.bkgColor,
                 radius  : 0,
                 align   : .left)
        
        // Day Text
        drawText(label   : dayLabel,
                 font    : dateFont!,
                 text    : dayFormatter.string(from: now),
                 frame   : CGRect(x: size * 0.05, y: height - size * 0.4, width: width - size * 0.1, height: height * 0.12),
                 fgdColor: tile.fgdColor,
                 bkgColor: tile.bkgColor,
                 radius  : 0,
                 align   : .left)
        
        UIGraphicsPopContext()
    }
}


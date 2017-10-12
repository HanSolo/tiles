//
//  SliderSkin.swift
//  Tiles
//
//  Created by Gerrit Grunwald on 12.10.17.
//  Copyright © 2017 Gerrit Grunwald. All rights reserved.
//

import UIKit

class SliderSkin: Skin {
    private let valueLabel           = AnimLabel()
    private let descriptionLabel     = UILabel()
    private var trackBackground      = UIBezierPath()
    private var trackBackgroundLayer = CAShapeLayer()
    private var track                = UIBezierPath()
    private var trackLayer           = CAShapeLayer()
    private var thumb                = UIBezierPath()
    private var thumbLayer           = CAShapeLayer()
    private var timer                = Timer()
    private var trackStart           = CGFloat(Helper.DEFAULT_SIZE * 0.14)
    private var trackLength          = CGFloat(Helper.DEFAULT_SIZE * 0.28)
    private var currentPosition      = CGPoint(x: 0, y: 0)
    private var dragStart            = CGPoint(x: 0, y: 0)
    private var formerThumbPos       = CGFloat(0.0)
    
    
    // ******************** Constructors **************
    override init() {
        super.init()
        valueLabel.method        = .easeInOut
        valueLabel.textAlignment = .right
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
            tile.addSubview(valueLabel)
            tile.addSubview(descriptionLabel)
            
            addSublayer(trackBackgroundLayer)
            addSublayer(trackLayer)
            addSublayer(thumbLayer)
            
            trackBackgroundLayer.path = trackBackground.cgPath
            trackLayer.path           = track.cgPath
            thumbLayer.path           = thumb.cgPath
        } else if (cmd == Helper.REDRAW) {
            setNeedsDisplay()
        }
    }
    override func update<T>(prop: String, value: T) {
        guard let tile = control else { return }
        if (prop == "value") {
            valueLabel.countFrom(tile.oldValue, to: tile.value, withDuration: 0.1)
            handleCurrentValue(tile: tile)
        } else if (prop == Helper.TOUCH_BEGAN) {
            if (thumb.contains(value as! CGPoint)) {
                dragStart      = value as! CGPoint
                formerThumbPos = (tile.value - tile.minValue) / tile.range
            }
        } else if (prop == Helper.TOUCH_MOVED) {
            currentPosition = value as! CGPoint
            let dragPos     = currentPosition.x - dragStart.x
            tile.value      = Helper.clamp(min: tile.minValue, max: tile.maxValue, value: ((formerThumbPos + dragPos / trackLength) * tile.range) + tile.minValue)
        } else if (prop == Helper.TOUCH_ENDED) {
            if (thumb.contains(value as! CGPoint)) {
                
            }
        }
    }
    
    private func handleCurrentValue(tile: Tile) {
        centerX = trackStart + (trackLength * ((tile.value - tile.minValue) / tile.range))
        
        track = UIBezierPath(roundedRect: CGRect(x: trackStart, y: centerY - size * 0.01375, width: centerX - trackStart, height: size * 0.0275), cornerRadius: size * 0.0275)        
        trackLayer.path      = track.cgPath
        trackLayer.fillColor = tile.barColor.cgColor
        
        thumb   = UIBezierPath(ovalIn: CGRect(x: centerX - size * 0.09, y: centerY - size * 0.09, width: size * 0.18, height: size * 0.18))
        thumbLayer.path            = thumb.cgPath
        thumbLayer.fillColor       = tile.value > tile.minValue ? tile.barColor.cgColor : tile.fgdColor.cgColor
        thumbLayer.shadowColor     = UIColor.black.cgColor
        thumbLayer.shadowOffset    = CGSize(width: 0.0, height: 0.0)
        thumbLayer.shadowOpacity   = 0.65
        thumbLayer.shadowRadius    = size * 0.008
        thumbLayer.shouldRasterize = true
        thumbLayer.rasterizationScale = UIScreen.main.scale
    }
    
    
    // ******************** Redraw ********************
    override func draw(in ctx: CGContext) {
        super.draw(in: ctx)
        guard let tile = control else { return }
        
        UIGraphicsPushContext(ctx)
        
        width       = self.frame.width
        height      = self.frame.height
        size        = width < height ? width : height
        trackStart  = size * 0.14
        trackLength = width - size * 0.28
        centerX     = trackStart + (trackLength * ((tile.value - tile.minValue) / tile.range))
        centerY     = height * 0.71
        
        // Background
        let path = UIBezierPath(roundedRect: bounds, cornerRadius: size * 0.025)
        ctx.setFillColor(tile.bkgColor.cgColor)
        ctx.addPath(path.cgPath)
        ctx.fillPath()
        
        let smallFont  = UIFont.init(name: "Lato-Regular", size: size * 0.06)
        let mediumFont = UIFont.init(name: "Lato-Regular", size: size * 0.1)
        let unitFont   = UIFont.init(name: "Lato-Regular", size: size * 0.12)
        let bigFont    = UIFont.init(name: "Lato-Regular", size: size * 0.24)
        
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
        
        // Description
        drawText(label   : descriptionLabel,
                 font    : mediumFont!,
                 text    : tile.descr,
                 frame   : CGRect(x: size * 0.05, y: size * 0.42, width: size * 0.9, height: size * 0.12),
                 fgdColor: tile.fgdColor,
                 bkgColor: UIColor.clear,
                 radius  : 0,
                 align   : .right)
        
        // Value
        valueLabel.frame = CGRect(x     : size * 0.05,
                                  y     : size * 0.15,
                                  width : width - size * 0.1,
                                  height: size * 0.288)
        setAttributedFormatBlock(label       : valueLabel,
                                 valueFont   : bigFont!,
                                 formatString: "%.\(tile.decimals)f",
            valueColor  : tile.valueColor,
            unit        : tile.unit,
            unitFont    : unitFont!,
            unitColor   : tile.unitColor)
        valueLabel.textAlignment   = .right
        valueLabel.numberOfLines   = 1
        valueLabel.backgroundColor = UIColor.clear
        valueLabel.setNeedsDisplay()
        valueLabel.countFrom(tile.oldValue, to: tile.value, withDuration: 0.1)
        
    
        // TrackBackground
        trackBackground = UIBezierPath(roundedRect: CGRect(x: trackStart, y: centerY - size * 0.01375, width: trackLength, height: size * 0.0275), cornerRadius: size * 0.0275)
        
        trackBackgroundLayer.path      = trackBackground.cgPath
        trackBackgroundLayer.fillColor = tile.barBackgroundColor.cgColor
        
        
        // Track
        track = UIBezierPath(roundedRect: CGRect(x: trackStart, y: centerY - size * 0.01375, width: centerX - trackStart, height: size * 0.0275), cornerRadius: size * 0.0275)
        
        trackLayer.path      = track.cgPath
        trackLayer.fillColor = tile.barColor.cgColor
        
        
        // Thumb
        thumb = UIBezierPath(ovalIn: CGRect(x: centerX - size * 0.09, y: centerY - size * 0.09, width: size * 0.18, height: size * 0.18))
        
        thumbLayer.path      = thumb.cgPath
        thumbLayer.fillColor = tile.value > tile.minValue ? tile.barColor.cgColor : tile.fgdColor.cgColor
        
        thumbLayer.shadowColor     = UIColor.black.cgColor
        thumbLayer.shadowOffset    = CGSize(width: 0.0, height: 0.0)
        thumbLayer.shadowOpacity   = 0.65
        thumbLayer.shadowRadius    = size * 0.008
        thumbLayer.shouldRasterize = true
        thumbLayer.rasterizationScale = UIScreen.main.scale
        
        UIGraphicsPopContext()
    }
}

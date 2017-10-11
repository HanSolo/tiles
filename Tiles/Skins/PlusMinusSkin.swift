//
//  PlusMinusSkin.swift
//  Tiles
//
//  Created by Gerrit Grunwald on 09.10.17.
//  Copyright © 2017 Gerrit Grunwald. All rights reserved.
//

import UIKit

class PlusMinusSkin: Skin {
    private let valueLabel       = AnimLabel()
    private let descriptionLabel = UILabel()
    private var plusButton       = UIBezierPath()
    private var plusLabel        = UILabel()
    private var plusLayer        = CAShapeLayer()
    private var minusButton      = UIBezierPath()
    private var minusLabel       = UILabel()
    private var minusLayer       = CAShapeLayer()
    private var timer            = Timer()
    
    
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
            tile.addSubview(plusLabel)
            tile.addSubview(minusLabel)
            
            addSublayer(plusLayer)
            addSublayer(minusLayer)
            
            plusLayer.path  = plusButton.cgPath
            minusLayer.path = minusButton.cgPath
        } else if (cmd == Helper.REDRAW) {
            setNeedsDisplay()
        }
    }
    override func update<T>(prop: String, value: T) {
        guard let tile = control else { return }
        if (prop == "value") {
            valueLabel.countFrom(tile.oldValue, to: tile.value, withDuration: 0.1)
        } else if (prop == Helper.TOUCH_BEGAN) {
            if (plusButton.contains(value as! CGPoint)) {
                increment(tile: tile)
            } else if (minusButton.contains(value as! CGPoint)) {
                decrement(tile: tile)
            }
        } else if (prop == Helper.TOUCH_ENDED) {
            if (plusButton.contains(value as! CGPoint)) {
                plusLabel.textColor   = tile.fgdColor
                plusLayer.strokeColor = tile.fgdColor.cgColor
            } else if (minusButton.contains(value as! CGPoint)) {
                minusLabel.textColor   = tile.fgdColor
                minusLayer.strokeColor = tile.fgdColor.cgColor
            }
        }
    }
    
    func increment(tile: Tile) {
        plusLabel.textColor   = tile.activeColor
        plusLayer.strokeColor = tile.activeColor.cgColor
        let newValue = Helper.clamp(min: tile.minValue, max: tile.maxValue, value: tile.value + tile.increment)
        tile.value = newValue        
    }
    func decrement(tile: Tile) {
        minusLabel.textColor   = tile.activeColor
        minusLayer.strokeColor = tile.activeColor.cgColor
        let newValue = Helper.clamp(min: tile.minValue, max: tile.maxValue, value: tile.value - tile.increment)
        tile.value = newValue
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
                 frame   :CGRect(x: size * 0.05, y: size * 0.42, width: size * 0.9, height: size * 0.12),
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
        
        
        // Buttons
        let buttonSize = size * 0.18
        drawText(label   : plusLabel,
                 font    : unitFont!,
                 text    : "+",
                 frame   :CGRect(x: width - size * 0.05 - buttonSize, y: height - size * 0.21 - buttonSize, width: buttonSize, height: buttonSize),
                 fgdColor: tile.fgdColor,
                 bkgColor: UIColor.clear,
                 radius  : 0,
                 align   : .center)
        
        drawText(label   : minusLabel,
                 font    : unitFont!,
                 text    : "-",
                 frame   :CGRect(x: size * 0.05, y: height - size * 0.21 - buttonSize, width: buttonSize, height: buttonSize),
                 fgdColor: tile.fgdColor,
                 bkgColor: UIColor.clear,
                 radius  : 0,
                 align   : .center)
        
        plusButton = UIBezierPath(ovalIn: CGRect(x: width - size * 0.05 - buttonSize, y: height - size * 0.2 - buttonSize, width: buttonSize, height: buttonSize))
        minusButton = UIBezierPath(ovalIn: CGRect(x: size * 0.05, y: height - size * 0.2 - buttonSize, width: buttonSize, height: buttonSize))
        
        plusLayer.path        = plusButton.cgPath
        plusLayer.lineWidth   = size * 0.01
        plusLayer.fillColor   = UIColor.clear.cgColor
        plusLayer.strokeColor = tile.fgdColor.cgColor
        
        minusLayer.path        = minusButton.cgPath
        minusLayer.lineWidth   = size * 0.01
        minusLayer.fillColor   = UIColor.clear.cgColor
        minusLayer.strokeColor = tile.fgdColor.cgColor
        
        UIGraphicsPopContext()
    }
}

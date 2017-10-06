//
//  NumberSkin.swift
//  Tiles
//
//  Created by Gerrit Grunwald on 04.10.17.
//  Copyright © 2017 Gerrit Grunwald. All rights reserved.
//

import UIKit

class NumberSkin: Skin {
    private let valueLabel       = AnimLabel()
    private let descriptionLabel = UILabel()
    
    
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
        } else if (cmd == Helper.REDRAW) {
            setNeedsDisplay()
        }
    }
    override func update<T>(prop: String, value: T) {
        guard let tile = control else { return }
        
        if (prop == "value") {
            valueLabel.countFrom(tile.oldValue, to: tile.value, withDuration: tile.animationDuration)
        }
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
                     frame   : CGRect(x: size * 0.05, y: size * 0.89, width: width - size * 0.1, height: size * 0.08),
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
                 bkgColor: tile.bkgColor,
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
        valueLabel.countFrom(tile.oldValue, to: tile.value, withDuration: tile.animationDuration)
        
        UIGraphicsPopContext()
    }
}

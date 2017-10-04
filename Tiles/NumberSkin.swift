//
//  NumberSkin.swift
//  Tiles
//
//  Created by Gerrit Grunwald on 04.10.17.
//  Copyright © 2017 Gerrit Grunwald. All rights reserved.
//

import UIKit

class NumberSkin: Skin {
    let valueLabel       = AnimLabel()
    let descriptionLabel = UILabel()
    
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
        if (cmd == Helper.INIT) {
            control!.addSubview(valueLabel)            
            control!.addSubview(descriptionLabel)
        } else if (cmd == Helper.REDRAW) {
            setNeedsDisplay()
        }
    }
    override func update<T>(prop: String, value: T) {
        if (prop == "value") {
            valueLabel.countFrom(control!.oldValue, to: control!.value, withDuration: control!.animationDuration)
        }
    }
    
    override func layoutSublayers() {
        super.layoutSublayers()
        
    }
    
    
    // ******************** Event Handling ************
    /*
     override func onTileEvent(event: TileEvent) {
     switch(event.type) {
     case .VALUE(let value): break
     case .REDRAW          : break
     case .RECALC          : break
     }
     }
     */
    
    
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
            let mediumFont = UIFont.init(name: "Lato-Regular", size: size * 0.1)
            let unitFont   = UIFont.init(name: "Lato-Regular", size: size * 0.12)
            let bigFont    = UIFont.init(name: "Lato-Regular", size: size * 0.24)
            
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
            
            // Description
            drawText(label   : descriptionLabel,
                     font    : mediumFont!,
                     text    : ctrl.descr,
                     frame   :CGRect(x: size * 0.05, y: size * 0.42, width: size * 0.9, height: size * 0.12),
                     fgdColor: ctrl.fgdColor,
                     bkgColor: ctrl.bkgColor,
                     radius  : 0,
                     align   : .right)
            
            // Value
            let formatString          = "%.\(ctrl.decimals)f"
            let tickLabelFormatString = "%.\(ctrl.tickLabelDecimals)f"
            
            valueLabel.frame = CGRect(x     : size * 0.05,
                                      y     : size * 0.15,
                                      width : width - size * 0.1,
                                      height: size * 0.288)
            setAttributedFormatBlock(label       : valueLabel,
                                     valueFont   : bigFont!,
                                     formatString: formatString,
                                     valueColor  : ctrl.valueColor,
                                     unit        : ctrl.unit,
                                     unitFont    : unitFont!,
                                     unitColor   : ctrl.unitColor)
            valueLabel.textAlignment   = .right
            valueLabel.numberOfLines   = 1
            valueLabel.backgroundColor = UIColor.clear
            valueLabel.setNeedsDisplay()
            valueLabel.countFrom(ctrl.oldValue, to: ctrl.value, withDuration: ctrl.animationDuration)
        }
        UIGraphicsPopContext()
    }
}

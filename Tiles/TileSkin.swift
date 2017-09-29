//
//  TileSkin.swift
//  Tiles
//
//  Created by Gerrit Grunwald on 29.09.17.
//  Copyright © 2017 Gerrit Grunwald. All rights reserved.
//

import UIKit

class TileSkin: Skin {
    var size   : CGFloat = Helper.DEFAULT_SIZE
    var center : CGFloat = Helper.DEFAULT_SIZE * 0.5
    
    
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
    
    
    // ******************** Redraw ********************
    override func draw(in ctx: CGContext) {
        super.draw(in: ctx)
        UIGraphicsPushContext(ctx)
        if let ctrl = control {
            size   = ctrl.size
            center = size * 0.5
            
            // Background
            let path = UIBezierPath(roundedRect: bounds, cornerRadius: size * 0.025)
            ctx.setFillColor(ctrl.bkgColor.cgColor)
            ctx.addPath(path.cgPath)
            ctx.fillPath()
            
            let smallFont  = UIFont.init(name: "Lato-Regular", size: size * 0.06)
            
            // Tile Title
            /*
            ctrl.titleLabel.text      = ctrl.title
            ctrl.titleLabel.textColor = ctrl.fgdColor
            ctrl.titleLabel.font      = smallFont
            ctrl.titleLabel.center    = CGPoint(x: size * 0.05, y: size * 0.05)
            ctrl.titleLabel.frame     = CGRect(x: size * 0.05, y: size * 0.05, width: frame.width - size * 0.1, height: size * 0.06)
            ctrl.titleLabel.setNeedsDisplay()
            */
            drawText(label: ctrl.titleLabel, font: smallFont!, text: ctrl.title, frame: CGRect(x: size * 0.05, y: size * 0.05, width: frame.width - size * 0.1, height: size * 0.06), fgdColor: ctrl.fgdColor, bkgColor: ctrl.bkgColor, radius: 0)
            
            // Tile Text
            ctrl.textLabel.text      = ctrl.text
            ctrl.textLabel.textColor = ctrl.fgdColor
            ctrl.textLabel.font      = smallFont
            ctrl.textLabel.center    = CGPoint(x: size * 0.05, y: size * 0.05)
            ctrl.textLabel.frame     = CGRect(x: size * 0.05, y: size * 0.89, width: frame.width - size * 0.1, height: size * 0.06)
            ctrl.textLabel.setNeedsDisplay()
        }
        UIGraphicsPopContext()
    }
    
    func drawText(label : UILabel, font: UIFont, text: String, frame: CGRect, fgdColor: UIColor, bkgColor: UIColor, radius: CGFloat) {
        label.textAlignment       = .center
        label.text                = text
        label.numberOfLines       = 1
        label.sizeToFit()
        label.frame               = frame
        label.textColor           = fgdColor
        label.backgroundColor     = bkgColor
        label.font                = font
        label.layer.masksToBounds = true
        label.layer.cornerRadius  = radius
        label.setNeedsDisplay()
    }
}

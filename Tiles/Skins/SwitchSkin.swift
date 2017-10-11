//
//  SwitchSkin.swift
//  Tiles
//
//  Created by Gerrit Grunwald on 06.10.17.
//  Copyright © 2017 Gerrit Grunwald. All rights reserved.
//

import UIKit

class SwitchSkin: Skin, CAAnimationDelegate {
    private var switchBorder          = UIBezierPath()
    private var switchBackground      = UIBezierPath()
    private var switchBackgroundLayer = CAShapeLayer()
    private var thumb                 = UIBezierPath()
    private var thumbLayer            = CAShapeLayer()
    
    
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
        //guard let tile = control else { return }
        
        if (cmd == Helper.INIT) {
            addSublayer(switchBackgroundLayer)
            addSublayer(thumbLayer)
            
            switchBackgroundLayer.path = switchBackground.cgPath
            thumbLayer.path            = thumb.cgPath
        } else if (cmd == Helper.REDRAW) {
            setNeedsDisplay()
        }
    }
    override func update<T>(prop: String, value: T) {
        guard let tile = control else { return }
        if (prop == "switch") {
            animateThumb(duration: 0.2, tile:tile)
        } else if (prop == Helper.TOUCH_BEGAN) {
            if (switchBorder.contains(value as! CGPoint)) { tile.active = !tile.active }
        }
    }
         
    func animateThumb(duration: TimeInterval, tile: Tile) {
        let thumbAnimation                   = CABasicAnimation(keyPath: "position")
        thumbAnimation.fromValue             = CGPoint(x: tile.active ? 0 : size * 0.23, y: 0)
        thumbAnimation.toValue               = CGPoint(x: tile.active ? size * 0.23 : 0, y: 0)
        thumbAnimation.duration              = duration
        thumbAnimation.timingFunction        = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        thumbAnimation.fillMode              = kCAFillModeForwards
        thumbAnimation.isRemovedOnCompletion = false
        thumbAnimation.delegate              = self
        
        let switchBackgroundAnimation                   = CABasicAnimation(keyPath: "fillColor")
        switchBackgroundAnimation.fromValue             = tile.active ? tile.bkgColor.cgColor    : tile.activeColor.cgColor
        switchBackgroundAnimation.toValue               = tile.active ? tile.activeColor.cgColor : tile.bkgColor.cgColor
        switchBackgroundAnimation.duration              = duration
        switchBackgroundAnimation.fillMode              = kCAFillModeBoth
        switchBackgroundAnimation.isRemovedOnCompletion = false
        
        thumbLayer.add(thumbAnimation, forKey: "position")
        switchBackgroundLayer.add(switchBackgroundAnimation, forKey: "fillColor")
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        
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
        
        switchBorder = UIBezierPath(roundedRect: CGRect(x: (width - size * 0.445) * 0.5, y: (height - size * 0.22) * 0.5, width: size * 0.445, height: size * 0.22), cornerRadius: size * 0.22)
        switchBackground = UIBezierPath(roundedRect: CGRect(x: (width - size * 0.425) * 0.5, y: (height - size * 0.2) * 0.5, width: size * 0.425, height: size * 0.2), cornerRadius: size * 0.2)
        thumb = UIBezierPath(ovalIn: CGRect(x: tile.active ? (width - size * 0.425) + size * 0.425 - size * 0.1 - size * 0.18 : (width - size * 0.425) - size * 0.1 - size * 0.18, y: centerY - size * 0.09, width: size * 0.18, height: size * 0.18))
        
        ctx.addPath(switchBorder.cgPath)
        ctx.setFillColor(tile.fgdColor.cgColor)
        ctx.fillPath()
        
        switchBackgroundLayer.path      = switchBackground.cgPath
        switchBackgroundLayer.fillColor = tile.active ? tile.activeColor.cgColor : tile.bkgColor.cgColor
        
        thumbLayer.path      = thumb.cgPath
        thumbLayer.fillColor = tile.fgdColor.cgColor
        
        thumbLayer.shadowColor     = UIColor.black.cgColor
        thumbLayer.shadowOffset    = CGSize(width: 0.0, height: 0.0)
        thumbLayer.shadowOpacity   = 0.65
        thumbLayer.shadowRadius    = size * 0.008
        thumbLayer.shouldRasterize = true
        thumbLayer.rasterizationScale = UIScreen.main.scale
        
        ctx.fillPath()
        
        UIGraphicsPopContext()
    }
}

//
//  HighLowSkin.swift
//  Tiles
//
//  Created by Gerrit Grunwald on 04.10.17.
//  Copyright © 2017 Gerrit Grunwald. All rights reserved.
//

import UIKit

class HighLowSkin: Skin {
    enum State {
        case INCREASE
        case DECREASE
        case CONSTANT
    }
    let valueLabel       = AnimLabel()
    let descriptionLabel = UILabel()
    let referenceLabel   = AnimLabel()
    var state            = State.CONSTANT { didSet { self.oldState = oldValue } }
    var oldState         = State.CONSTANT
    var percentageFont   = UIFont.init(name: "Lato-Regular", size: Helper.DEFAULT_SIZE * 0.18)
    var unitFont         = UIFont.init(name: "Lato-Regular", size: Helper.DEFAULT_SIZE * 0.12)
    var mediumFont       = UIFont.init(name: "Lato-Regular", size: Helper.DEFAULT_SIZE * 0.1)
    var bigFont          = UIFont.init(name: "Lato-Regular", size: Helper.DEFAULT_SIZE * 0.24)
    var triangleLayer    = CAShapeLayer()
    
    
    // ******************** Constructors **************
    override init() {
        super.init()        
        valueLabel.method        = .easeInOut
        valueLabel.textAlignment = .right
        
        triangleLayer.anchorPoint = CGPoint(x: 0.5, y: 1.0)
        addSublayer(triangleLayer)
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
            tile.addSubview(referenceLabel)
            tile.addSubview(descriptionLabel)
        } else if (cmd == Helper.REDRAW) {
            setNeedsDisplay()
        }
    }
    override func update<T>(prop: String, value: T) {
        guard let tile = control else { return }
        
        if (prop == "value") {
            updateState(value: tile.value, referenceValue: tile.referenceValue, tile:tile)
            valueLabel.countFrom(tile.oldValue, to: tile.value, withDuration: tile.animationDuration)
            referenceLabel.countFrom(tile.referenceValue, to: tile.referenceValue, withDuration: 0)
        }
    }
    
    
    func updateState(value : CGFloat, referenceValue : CGFloat, tile : Tile) {
        if (value > referenceValue) {
            state = .INCREASE
        } else if (value < referenceValue) {
            state = .DECREASE
        } else {
            state = .CONSTANT
        }
        animateTriangle(tile: tile)
        setAttributedFormatBlock(label       : referenceLabel,
                                 valueFont   : percentageFont!,
                                 formatString: "%.\(tile.tickLabelDecimals)f",
                                 valueColor  : getStateColor(),
                                 unit        : tile.unit,
                                 unitFont    : unitFont!,
                                 unitColor   : getStateColor())
        triangleLayer.fillColor = getStateColor().cgColor
    }
    
    func animateTriangle(tile: Tile) {
        UIView.animate(withDuration: tile.animationDuration, delay: 0.0, options: .curveEaseInOut, animations: {
            var angle = CGFloat(0.0)
            switch(self.state) {
            case .INCREASE : angle = .pi * 0.0; break
            case .DECREASE : angle = .pi * 1.0; break
            case .CONSTANT : angle = .pi * 0.5; break
            }            
            self.triangleLayer.transform = CATransform3DMakeRotation(angle, 0.0, 0.0, 1.0)
        }, completion: nil)
    }
    
    func getStateColor() -> UIColor {
        switch(state) {
        case .INCREASE: return Helper.GREEN
        case .DECREASE: return Helper.RED
        case .CONSTANT: return Helper.ORANGE
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
        
        mediumFont     = UIFont.init(name: "Lato-Regular", size: size * 0.1)
        unitFont       = UIFont.init(name: "Lato-Regular", size: size * 0.12)
        percentageFont = UIFont.init(name: "Lato-Regular", size: size * 0.18)
        bigFont        = UIFont.init(name: "Lato-Regular", size: size * 0.24)
        
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
        let formatString          = "%.\(tile.decimals)f"
        let tickLabelFormatString = "%.\(tile.tickLabelDecimals)f"
        
        valueLabel.frame = CGRect(x     : size * 0.05,
                                  y     : size * 0.15,
                                  width : width - size * 0.1,
                                  height: size * 0.288)
        setAttributedFormatBlock(label       : valueLabel,
                                 valueFont   : bigFont!,
                                 formatString: formatString,
                                 valueColor  : tile.valueColor,
                                 unit        : tile.unit,
                                 unitFont    : unitFont!,
                                 unitColor   : tile.unitColor)
        valueLabel.textAlignment   = .right
        valueLabel.numberOfLines   = 1
        valueLabel.backgroundColor = UIColor.clear
        valueLabel.setNeedsDisplay()
        valueLabel.countFrom(tile.oldValue, to: tile.value, withDuration: tile.animationDuration)
        
        // Reference
        referenceLabel.frame = CGRect(x     : size * 0.2,
                                      y     : height - size * 0.36,
                                      width : width - size * 0.25,
                                      height: size * 0.21)
        setAttributedFormatBlock(label       : referenceLabel,
                                 valueFont   : percentageFont!,
                                 formatString: tickLabelFormatString,
                                 valueColor  : getStateColor(),
                                 unit        : tile.unit,
                                 unitFont    : unitFont!,
                                 unitColor   : getStateColor())
        referenceLabel.textAlignment   = .left
        referenceLabel.numberOfLines   = 1
        referenceLabel.backgroundColor = UIColor.clear
        referenceLabel.setNeedsDisplay()
        referenceLabel.countFrom(tile.referenceValue, to: tile.referenceValue, withDuration: tile.animationDuration)
        
        // Triangle
        let triangle = UIBezierPath()
        triangle.move(to: CGPoint(x: 0.056 * size, y: 0.032 * size))
        triangle.addCurve(to: CGPoint(x: 0.068 * size, y: 0.032 * size), controlPoint1: CGPoint(x: 0.060 * size, y: 0.028 * size), controlPoint2: CGPoint(x: 0.064 * size, y: 0.028 * size))
        triangle.addCurve(to: CGPoint(x: 0.120 * size, y: 0.080 * size), controlPoint1: CGPoint(x: 0.068 * size, y: 0.032 * size), controlPoint2: CGPoint(x: 0.120 * size, y: 0.080 * size))
        triangle.addCurve(to: CGPoint(x: 0.112 * size, y: 0.096 * size), controlPoint1: CGPoint(x: 0.128 * size, y: 0.088 * size), controlPoint2: CGPoint(x: 0.124 * size, y: 0.096 * size))
        triangle.addCurve(to: CGPoint(x: 0.012 * size, y: 0.096 * size), controlPoint1: CGPoint(x: 0.112 * size, y: 0.096 * size), controlPoint2: CGPoint(x: 0.012 * size, y: 0.096 * size))
        triangle.addCurve(to: CGPoint(x: 0.004 * size, y: 0.080 * size), controlPoint1: CGPoint(x: 0.0, y: 0.096 * size), controlPoint2: CGPoint(x: -0.004 * size, y: 0.088 * size))
        triangle.addCurve(to: CGPoint(x: 0.056 * size, y: 0.032 * size), controlPoint1: CGPoint(x: 0.004 * size, y: 0.080 * size), controlPoint2: CGPoint(x: 0.056 * size, y: 0.032 * size))
        triangle.close()
        
        triangleLayer.path      = triangle.cgPath
        triangleLayer.fillColor = getStateColor().cgColor
        triangleLayer.frame     = triangle.bounds
        triangleLayer.position  = CGPoint(x: size * 0.1, y: size * 0.75)
        
        UIGraphicsPopContext()
    }
}

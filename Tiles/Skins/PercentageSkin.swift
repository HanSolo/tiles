//
//  PercentageSkin.swift
//  Tiles
//
//  Created by Gerrit Grunwald on 01.10.17.
//  Copyright © 2017 Gerrit Grunwald. All rights reserved.
//

import UIKit

class PercentageSkin: Skin {
    private let valueLabel           = AnimLabel()
    private let percentageValueLabel = AnimLabel()
    private let descriptionLabel     = UILabel()
    private let maxValueLabel        = UILabel()
    private let barLayer             = CAShapeLayer()
    private var bar                  = UIBezierPath()
    private var startTime            = 0.0
    private var stepSize             = CGFloat(0.0)
    private var displayLink          : CADisplayLink?
    
    
    // ******************** Constructors ********************
    override init() {
        super.init()
        
        percentageValueLabel.method        = .easeInOut
        percentageValueLabel.textAlignment = .right
        
        valueLabel.method        = .easeInOut
        valueLabel.format        = "%.1f"
        valueLabel.textAlignment = .right
        
        bar = UIBezierPath(roundedRect      : CGRect(x: 0, y: height - size * 0.035, width: 0, height: size * 0.035),
                           byRoundingCorners: [UIRectCorner.bottomLeft, UIRectCorner.bottomRight],
                           cornerRadii      : CGSize(width: size * 0.05, height: size * 0.05))

        barLayer.path        = bar.cgPath
        barLayer.strokeColor = UIColor.clear.cgColor
        barLayer.fillColor   = Helper.BLUE.cgColor
        addSublayer(barLayer)
    }
    override init(layer: Any) {
        super.init(layer: layer)
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    // ******************** Methods ********************
    override func update(cmd: String) {
        guard let tile = control else { return }
        
        if (cmd == Helper.INIT) {
            tile.textVisible    = false
            tile.thresholdColor = Helper.GRAY
            tile.threshold      = tile.maxValue
            tile.addSubview(percentageValueLabel)
            tile.addSubview(valueLabel)
            tile.addSubview(descriptionLabel)
            tile.addSubview(maxValueLabel)
        } else if (cmd == Helper.REDRAW) {
            setNeedsDisplay()
        }
    }
    override func update<T>(prop: String, value: T) {
        guard let tile = control else { return }
        
        if (prop == "value") {
            // Calculate stepSize
            stepSize = (tile.value - tile.oldValue) / CGFloat(tile.animationDuration)
            startDisplayLink()
            
            valueLabel.countFrom(tile.oldValue, to: tile.value, withDuration: tile.animationDuration)
            percentageValueLabel.countFrom((tile.oldValue / tile.range * 100.0), to: (tile.value / tile.range * 100.0), withDuration: tile.animationDuration)
            
            animateBar(duration: tile.animationDuration, tile:tile)
        }
    }
    
    func startDisplayLink() {
        // make sure to stop a previous running display link
        stopDisplayLink()
        
        // reset start time
        startTime = CACurrentMediaTime()
        
        // create displayLink & add it to the run-loop
        displayLink = CADisplayLink(target: self, selector: #selector(displayLinkDidFire))
        displayLink?.preferredFramesPerSecond = 6
        displayLink?.add(to: .main, forMode: .commonModes)
    }
    func stopDisplayLink() {
        displayLink?.invalidate()
        displayLink = nil
    }
    @objc func displayLinkDidFire(displayLink: CADisplayLink) {
        guard let tile = control else { return }
        var elapsed = CACurrentMediaTime() - startTime
        if elapsed > tile.animationDuration {
            stopDisplayLink()
            elapsed = tile.animationDuration // clamp the elapsed time to the anim length
        }
        let currentValue = tile.oldValue + CGFloat(elapsed) * stepSize
        handleCurrentValue(tile: tile, value: currentValue)
    }
    func handleCurrentValue(tile: Tile, value: CGFloat) {
        maxValueLabel.backgroundColor = value > tile.maxValue ? tile.barColor : tile.thresholdColor        
    }
    
    func animateBar(duration: TimeInterval, tile: Tile) {
        bar = UIBezierPath(roundedRect      : CGRect(x: 0, y: height - size * 0.035,
                                                     width: Helper.clamp(min: 0, max: size, value:(tile.oldValue / tile.range) * size), height: size * 0.035),
                           byRoundingCorners: [UIRectCorner.bottomLeft, UIRectCorner.bottomRight],
                           cornerRadii      : CGSize(width: size * 0.05, height: size * 0.05))
        let toPath = UIBezierPath(roundedRect      : CGRect(x: 0, y: height - size * 0.035,
                                                            width: Helper.clamp(min: 0, max: size, value:(tile.value / tile.range) * size), height: size * 0.035),
                                  byRoundingCorners: [UIRectCorner.bottomLeft, UIRectCorner.bottomRight],
                                  cornerRadii      : CGSize(width: size * 0.05, height: size * 0.05))
        let animation                   = CABasicAnimation(keyPath: "path")
        animation.fromValue             = bar.cgPath
        animation.toValue               = toPath.cgPath
        animation.duration              = duration
        animation.timingFunction        = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        animation.fillMode              = kCAFillModeForwards
        animation.isRemovedOnCompletion = false
        barLayer.add(animation, forKey: "animateBar")
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
                 frame   : CGRect(x: size * 0.05, y: size * 0.05, width: width - size * 0.1, height: size * 0.08),
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
        
        let barBackground = UIBezierPath(roundedRect      : CGRect(x: 0, y: height - size * 0.035, width: width, height: size * 0.035),
                                         byRoundingCorners: [UIRectCorner.bottomLeft, UIRectCorner.bottomRight],
                                         cornerRadii      : CGSize(width: size * 0.05, height: size * 0.05))
        tile.barBackgroundColor.brighter(by: 7)?.setFill()
        barBackground.fill()
        
        bar = UIBezierPath(roundedRect      : CGRect(x: 0, y: height - size * 0.035, width: (tile.value / tile.range) * width, height: size * 0.035),
                           byRoundingCorners: [UIRectCorner.bottomLeft, UIRectCorner.bottomRight],
                           cornerRadii      : CGSize(width: size * 0.05, height: size * 0.05))
        barLayer.fillColor = tile.barColor.cgColor
        
        // Value
        let formatString          = "%.\(tile.decimals)f"
        let tickLabelFormatString = "%.\(tile.tickLabelDecimals)f"
        
        let biggerFont         = UIFont.init(name: "Lato-Regular", size: size * 0.08)
        let mediumFont         = UIFont.init(name: "Lato-Regular", size: size * 0.1)
        let unitFont           = UIFont.init(name: "Lato-Regular", size: size * 0.12)
        let percentageFont     = UIFont.init(name: "Lato-Regular", size: size * 0.18)
        let bigFont            = UIFont.init(name: "Lato-Regular", size: size * 0.24)
        
        valueLabel.frame = CGRect(x     : size * 0.05,
                                  y     : size * 0.15,
                                  width : size * 0.9,
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
        
        // Percentage
        percentageValueLabel.frame = CGRect(x     : size * 0.05,
                                            y     : height - size * 0.36,
                                            width : size * 0.9,
                                            height: size * 0.21)
        setAttributedFormatBlock(label       : percentageValueLabel,
                                 valueFont   : percentageFont!,
                                 formatString: formatString,
                                 valueColor  : tile.barColor,
                                 unit        : "%",
                                 unitFont    : unitFont!,
                                 unitColor   : tile.barColor)
        percentageValueLabel.textAlignment   = .left
        percentageValueLabel.numberOfLines   = 1
        percentageValueLabel.backgroundColor = UIColor.clear
        percentageValueLabel.setNeedsDisplay()
        percentageValueLabel.countFrom((tile.oldValue / tile.range * 100.0), to: (tile.value / tile.range * 100.0), withDuration: tile.animationDuration)
        
        // Description
        drawText(label   : descriptionLabel,
                 font    : mediumFont!,
                 text    : tile.descr,
                 frame   :CGRect(x: size * 0.05, y: size * 0.42, width: size * 0.9, height: size * 0.12),
                 fgdColor: tile.fgdColor,
                 bkgColor: tile.bkgColor,
                 radius  : 0,
                 align   : .right)
        
        // Threshold Text
        maxValueLabel.textAlignment       = .center
        maxValueLabel.text                = String(format: tickLabelFormatString, tile.maxValue)
        maxValueLabel.numberOfLines       = 1
        maxValueLabel.sizeToFit()
        maxValueLabel.frame               = CGRect(x     : 0.5,
                                                   y     : 0.5,
                                                   width : (maxValueLabel.frame.width + size * 0.05),
                                                   height: size * 0.09)
        maxValueLabel.center              = CGPoint(x: (width - size * 0.05) - (maxValueLabel.frame.width * 0.5 + size * 0.05) * 0.75, y: height - size * 0.2225)
        maxValueLabel.textColor           = tile.bkgColor
        maxValueLabel.backgroundColor     = tile.value > tile.maxValue ? tile.barColor : tile.thresholdColor
        maxValueLabel.layer.masksToBounds = true
        maxValueLabel.layer.cornerRadius  = size * 0.0125
        maxValueLabel.font                = biggerFont!
        maxValueLabel.setNeedsDisplay()
        
        UIGraphicsPopContext()
    }
}

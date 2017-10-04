//
//  PercentageSkin.swift
//  Tiles
//
//  Created by Gerrit Grunwald on 01.10.17.
//  Copyright © 2017 Gerrit Grunwald. All rights reserved.
//

import UIKit

class PercentageSkin: Skin {
    let valueLabel            = AnimLabel()
    let percentageValueLabel  = AnimLabel()
    let descriptionLabel      = UILabel()
    let maxValueLabel         = UILabel()
    
    let barLayer              = CAShapeLayer()
    var bar                   = UIBezierPath()
    
    
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
        if (cmd == Helper.INIT) {
            control!.textVisible    = false
            control!.thresholdColor = Helper.GRAY
            control!.threshold      = control!.maxValue
            control!.addSubview(percentageValueLabel)
            control!.addSubview(valueLabel)
            control!.addSubview(descriptionLabel)
            control!.addSubview(maxValueLabel)
        } else if (cmd == Helper.REDRAW) {
            setNeedsDisplay()
        }
    }
    override func update<T>(prop: String, value: T) {
        if (prop == "value") {
            valueLabel.countFrom(control!.oldValue, to: control!.value, withDuration: control!.animationDuration)
            percentageValueLabel.countFrom((control!.oldValue / control!.range * 100.0), to: (control!.value / control!.range * 100.0), withDuration: control!.animationDuration)
    
            maxValueLabel.backgroundColor = control!.value > control!.maxValue ? control!.barColor : control!.thresholdColor
            maxValueLabel.setNeedsDisplay()
            
            animateBar(duration: control!.animationDuration)
        }
    }
    
    override func layoutSublayers() {
        super.layoutSublayers()
    }
    
    func animateBar(duration: TimeInterval) {
        bar = UIBezierPath(roundedRect      : CGRect(x: 0, y: size - size * 0.035, width: Helper.clamp(min: 0, max: size, value:(control!.oldValue / control!.range) * size), height: size * 0.035),
                           byRoundingCorners: [UIRectCorner.bottomLeft, UIRectCorner.bottomRight],
                           cornerRadii      : CGSize(width: size * 0.05, height: size * 0.05))
        let toPath = UIBezierPath(roundedRect      : CGRect(x: 0, y: size - size * 0.035, width: Helper.clamp(min: 0, max: size, value:(control!.value / control!.range) * size), height: size * 0.035),
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
                     frame   : CGRect(x: size * 0.05, y: size * 0.05, width: width - size * 0.1, height: size * 0.08),
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
            
            let barBackground = UIBezierPath(roundedRect      : CGRect(x: 0, y: height - size * 0.035, width: size, height: size * 0.035),
                                             byRoundingCorners: [UIRectCorner.bottomLeft, UIRectCorner.bottomRight],
                                             cornerRadii      : CGSize(width: size * 0.05, height: size * 0.05))
            ctrl.barBackgroundColor.brighter(by: 7)?.setFill()
            barBackground.fill()
            
            bar = UIBezierPath(roundedRect      : CGRect(x: 0, y: height - size * 0.035, width: (ctrl.value / ctrl.range) * size, height: size * 0.035),
                               byRoundingCorners: [UIRectCorner.bottomLeft, UIRectCorner.bottomRight],
                               cornerRadii      : CGSize(width: size * 0.05, height: size * 0.05))
            barLayer.fillColor = ctrl.barColor.cgColor
            
            // Value
            let formatString          = "%.\(ctrl.decimals)f"
            let tickLabelFormatString = "%.\(ctrl.tickLabelDecimals)f"
            
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
                                     valueColor  : ctrl.valueColor,
                                     unit        : ctrl.unit,
                                     unitFont    : unitFont!,
                                     unitColor   : ctrl.unitColor)
            valueLabel.textAlignment   = .right
            valueLabel.numberOfLines   = 1
            valueLabel.backgroundColor = UIColor.clear
            valueLabel.setNeedsDisplay()
            valueLabel.countFrom(ctrl.oldValue, to: ctrl.value, withDuration: ctrl.animationDuration)
            
            // Percentage
            percentageValueLabel.frame = CGRect(x     : size * 0.05,
                                                y     : height - size * 0.36,
                                                width : size * 0.9,
                                                height: size * 0.21)
            setAttributedFormatBlock(label       : percentageValueLabel,
                                     valueFont   : percentageFont!,
                                     formatString: formatString,
                                     valueColor  : ctrl.barColor,
                                     unit        : "%",
                                     unitFont    : unitFont!,
                                     unitColor   : ctrl.barColor)
            percentageValueLabel.textAlignment   = .left
            percentageValueLabel.numberOfLines   = 1
            percentageValueLabel.backgroundColor = UIColor.clear
            percentageValueLabel.setNeedsDisplay()
            percentageValueLabel.countFrom((ctrl.oldValue / ctrl.range * 100.0), to: (ctrl.value / ctrl.range * 100.0), withDuration: ctrl.animationDuration)
            
            drawText(label   : descriptionLabel,
                     font    : mediumFont!,
                     text    : ctrl.descr,
                     frame   :CGRect(x: size * 0.05, y: size * 0.42, width: size * 0.9, height: size * 0.12),
                     fgdColor: ctrl.fgdColor,
                     bkgColor: ctrl.bkgColor,
                     radius  : 0,
                     align   : .right)
            
            // Threshold Text
            maxValueLabel.textAlignment       = .center
            maxValueLabel.text                = String(format: tickLabelFormatString, ctrl.maxValue)
            maxValueLabel.numberOfLines       = 1
            maxValueLabel.sizeToFit()
            maxValueLabel.frame               = CGRect(x     : 0.5,
                                                       y     : 0.5,
                                                       width : (maxValueLabel.frame.width + size * 0.05),
                                                       height: size * 0.09)
            maxValueLabel.center              = CGPoint(x: (width - size * 0.05) - (maxValueLabel.frame.width * 0.5 + size * 0.05) * 0.75, y: height - size * 0.2225)
            maxValueLabel.textColor           = ctrl.bkgColor
            maxValueLabel.backgroundColor     = ctrl.value > ctrl.maxValue ? ctrl.barColor : ctrl.thresholdColor
            maxValueLabel.layer.masksToBounds = true
            maxValueLabel.layer.cornerRadius  = size * 0.0125
            maxValueLabel.font                = biggerFont!
            maxValueLabel.setNeedsDisplay()
        }
        UIGraphicsPopContext()
    }
}

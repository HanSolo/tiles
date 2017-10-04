//
//  CircularProgressSkin.swift
//  Tiles
//
//  Created by Gerrit Grunwald on 30.09.17.
//  Copyright © 2017 Gerrit Grunwald. All rights reserved.
//

import UIKit

class CircularProgressSkin: Skin {
    var chartSize   : CGFloat = 0.0
    var y           : CGFloat = 0
    let valueLabel            = AnimLabel()
    let percentageValueLabel  = AnimLabel()
    let startAngle            = CGFloat(.pi * 0.5)
    let barLayer              = CAShapeLayer()
    var bar                   = UIBezierPath()
    
    
    // ******************** Constructors ********************
    override init() {
        super.init()
        
        percentageValueLabel.method = .easeInOut        
        
        valueLabel.method = .easeInOut
        valueLabel.format = "%.1f"
        
        bar = UIBezierPath(arcCenter: CGPoint(x: centerX, y: centerY),
                           radius    : size * 0.4135,
                           startAngle: -startAngle,
                           endAngle  : -startAngle + .pi * 2.0,
                           clockwise : true)
        
        barLayer.path      = bar.cgPath
        barLayer.fillColor = UIColor.clear.cgColor
        barLayer.strokeEnd = 0.0
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
            control!.addSubview(percentageValueLabel)
            control!.addSubview(valueLabel)
            control!.addTileEventListener(listener: self)
        } else if (cmd == Helper.REDRAW) {
            setNeedsDisplay()
        }
    }
    override func update<T>(prop: String, value: T) {
        if (prop == "value") {
            percentageValueLabel.countFrom((control!.oldValue / control!.range * 100.0), to: (control!.value / control!.range * 100.0), withDuration: control!.animationDuration)
            valueLabel.countFrom(control!.oldValue, to: control!.value, withDuration: control!.animationDuration)
            animateBar(duration: control!.animationDuration)
        }
    }
    
    override func layoutSublayers() {
        super.layoutSublayers()
        
    }
    
    func animateBar(duration: TimeInterval) {
        let animation            = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue      = (control!.oldValue / control!.range) // 0 -> no circle
        animation.toValue        = (control!.value / control!.range)    // 1 -> full circle
        animation.duration       = duration
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        barLayer.strokeEnd       = (control!.value / control!.range) // end value after animation
        barLayer.add(animation, forKey: "animateBar")
    }
    
    override func onTileEvent(event: TileEvent) {
        switch(event.type) {
        case .VALUE(let value): break
        case .REDRAW          : break
        case .RECALC          : break
        }
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
            
            let chartWidth  = width * 0.9
            let chartHeight = ctrl.textVisible ? (size * 0.72) : (size * 0.795)
            chartSize       = chartWidth < chartHeight ? chartWidth : chartHeight
            y = size * 0.15 + (size * (ctrl.textVisible ? 0.75 : 0.85) - chartSize) * 0.5
            
            let barBackground = UIBezierPath(arcCenter : CGPoint(x: centerX, y: y + chartSize * 0.5),
                                             radius    : chartSize * 0.4135,
                                             startAngle: 0,
                                             endAngle  : .pi * 2.0,
                                             clockwise : true)
            barBackground.lineWidth = chartSize * 0.1
            ctrl.barBackgroundColor.brighter(by: 7)?.setStroke()
            barBackground.stroke()
            
            bar = UIBezierPath(arcCenter : CGPoint(x: centerX, y: y + chartSize * 0.5),
                               radius    : chartSize * 0.4135,
                               startAngle: -startAngle,
                               endAngle  : -startAngle + .pi * 2.0,
                               clockwise : true)
            barLayer.path        = bar.cgPath
            barLayer.strokeColor = ctrl.barColor.cgColor
            barLayer.lineWidth   = chartSize * 0.1
            
            let formatString       = "%.\(ctrl.decimals)f"
            
            let unitFont           = UIFont.init(name: "Lato-Regular", size: chartSize * (ctrl.graphicContainerVisible ? 0.035 : 0.04))
            let percentageUnitFont = UIFont.init(name: "Lato-Regular", size: chartSize * (ctrl.graphicContainerVisible ? 0.07 : 0.08))
            let mediumFont         = UIFont.init(name: "Lato-Regular", size: chartSize * (ctrl.graphicContainerVisible ? 0.075 : 0.1))
            let bigFont            = UIFont.init(name: "Lato-Regular", size: chartSize * (ctrl.graphicContainerVisible ? 0.15 : 0.2))
            
            percentageValueLabel.frame = CGRect(x     : size * 0.05,
                                                y     : centerY - size * 0.35,
                                                width : size * 0.9,
                                                height: size * 0.288)
            setAttributedFormatBlock(label       : percentageValueLabel,
                                     valueFont   : bigFont!,
                                     formatString: formatString,
                                     valueColor  : ctrl.valueColor,
                                     unit        : "%",
                                     unitFont    : percentageUnitFont!,
                                     unitColor   : ctrl.unitColor)
            percentageValueLabel.textAlignment   = .center
            percentageValueLabel.numberOfLines   = 1
            percentageValueLabel.backgroundColor = UIColor.clear
            percentageValueLabel.center          = CGPoint(x: size * 0.5, y: y + chartSize * 0.5)
            percentageValueLabel.setNeedsDisplay()
            percentageValueLabel.countFrom((ctrl.oldValue / ctrl.range * 100.0), to: (ctrl.value / ctrl.range * 100.0), withDuration: ctrl.animationDuration)
            
            valueLabel.frame = CGRect(x: 0, y: 0, width: size * 0.9, height:size * 0.12)
            setAttributedFormatBlock(label       : valueLabel,
                                     valueFont   : mediumFont!,
                                     formatString: formatString,
                                     valueColor  : ctrl.valueColor,
                                     unit        : ctrl.unit,
                                     unitFont    : unitFont!,
                                     unitColor   : ctrl.unitColor)
            valueLabel.textAlignment   = .center
            valueLabel.numberOfLines   = 1
            valueLabel.backgroundColor = UIColor.clear
            valueLabel.center          = CGPoint(x: size * 0.5,
                                                 y: ctrl.graphicContainerVisible ? (y + chartSize * 0.5 - chartSize * 0.22) : (y + chartSize * 0.5 + chartSize * 0.22))
            valueLabel.setNeedsDisplay()
            valueLabel.countFrom(control!.oldValue, to: control!.value, withDuration: ctrl.animationDuration)
        }
        UIGraphicsPopContext()
    }
}

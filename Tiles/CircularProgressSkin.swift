//
//  CircularProgressSkin.swift
//  Tiles
//
//  Created by Gerrit Grunwald on 30.09.17.
//  Copyright © 2017 Gerrit Grunwald. All rights reserved.
//

import UIKit

class CircularProgressSkin: Skin {
    var size      : CGFloat = Helper.DEFAULT_SIZE
    var center    : CGFloat = Helper.DEFAULT_SIZE * 0.5
    var chartSize : CGFloat = 0.0
    var y         : CGFloat = 0
    let valueLabel            = AnimLabel()
    let percentageValueLabel  = AnimLabel()
    let startAngle            = CGFloat(.pi * 0.5)
    let barLayer              = CAShapeLayer()
    var bar                   = UIBezierPath()
    
    
    // ******************** Constructors ********************
    override init() {
        super.init()
        
        percentageValueLabel.method = .easeInOut
        percentageValueLabel.format = "%.1f%%"
        
        valueLabel.method = .easeInOut
        valueLabel.format = "%.1f"
        
        bar = UIBezierPath(arcCenter: CGPoint(x: center, y: center),
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
            control!.addSubview(valueLabel)
            control!.addSubview(percentageValueLabel)
        } else if (cmd == Helper.REDRAW) {
            setNeedsDisplay()
        }
    }
    override func update<T>(prop: String, value: T) {
        if (prop == "value") {
            percentageValueLabel.countFrom((control!.oldValue / control!.range * 100.0), to: (control!.value / control!.range * 100.0), withDuration: control!.animationDuration)
            valueLabel.countFrom(control!.oldValue, to: control!.value, withDuration: control!.animationDuration)
            animateBar(duration: 1.5)
        }
    }
    
    override func layoutSublayers() {
        super.layoutSublayers()
        
    }
    
    func animateBar(duration: TimeInterval) {
        let animation            = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration       = control!.animationDuration
        animation.fromValue      = (control!.oldValue / control!.range) // 0 -> no circle
        animation.toValue        = (control!.value / control!.range)    // 1 -> full circle
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        barLayer.strokeEnd       = (control!.value / control!.range) // end value after animation
                
        barLayer.add(animation, forKey: "animateBar")
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
            drawText(label: ctrl.titleLabel, font: smallFont!, text: ctrl.title, frame: CGRect(x: size * 0.05, y: size * 0.05, width: frame.width - size * 0.1, height: size * 0.08), fgdColor: ctrl.fgdColor, bkgColor: ctrl.bkgColor, radius: 0, align: .left)
            
            // Tile Text
            if (ctrl.textVisible) {
                drawText(label: ctrl.textLabel, font: smallFont!, text: ctrl.text, frame: CGRect(x: size * 0.05, y: size * 0.89, width: frame.width - size * 0.1, height: size * 0.08), fgdColor: ctrl.fgdColor, bkgColor: ctrl.bkgColor, radius: 0, align: .left)
            } else {
                ctrl.textLabel.textColor = UIColor.clear
            }
            
            let chartWidth  = size * 0.9
            let chartHeight = ctrl.textVisible ? (size * 0.72) : (size * 0.795)
            chartSize       = chartWidth < chartHeight ? chartWidth : chartHeight
            y = size * 0.15 + (size * (ctrl.textVisible ? 0.75 : 0.85) - chartSize) * 0.5
            
            let barBackground = UIBezierPath(arcCenter: CGPoint(x: center, y: y + chartSize * 0.5),
                                             radius    : chartSize * 0.4135,
                                             startAngle: 0,
                                             endAngle  : .pi * 2.0,
                                             clockwise : true)
            barBackground.lineWidth = chartSize * 0.1
            ctrl.barBackgroundColor.brighter(by: 7)?.setStroke()
            barBackground.stroke()
            
            bar = UIBezierPath(arcCenter: CGPoint(x: center, y: y + chartSize * 0.5),
                               radius    : chartSize * 0.4135,
                               startAngle: -startAngle,
                               endAngle  : -startAngle + .pi * 2.0,
                               clockwise : true)
            barLayer.path        = bar.cgPath
            barLayer.strokeColor = ctrl.barColor.cgColor
            barLayer.lineWidth   = chartSize * 0.1
            
            let mediumFont = UIFont.init(name: "Lato-Regular", size: chartSize * (ctrl.graphicContainerVisible ? 0.075 : 0.1))
            let bigFont    = UIFont.init(name: "Lato-Regular", size: chartSize * (ctrl.graphicContainerVisible ? 0.15 : 0.2))
            
            percentageValueLabel.frame           = CGRect(x: size * 0.05, y: center - size * 0.35, width: size * 0.9, height:size * 0.288)
            percentageValueLabel.textAlignment   = .center
            percentageValueLabel.countFrom((control!.oldValue / control!.range * 100.0), to: (control!.value / control!.range * 100.0), withDuration: 1.5)
            percentageValueLabel.numberOfLines   = 1
            percentageValueLabel.textColor       = ctrl.fgdColor
            percentageValueLabel.backgroundColor = UIColor.clear
            percentageValueLabel.font            = bigFont
            percentageValueLabel.center          = CGPoint(x: size * 0.5, y: y + chartSize * 0.5)
            percentageValueLabel.setNeedsDisplay()
            
            valueLabel.frame           = CGRect(x: 0, y: 0, width: size * 0.9, height:size * 0.12)
            valueLabel.textAlignment   = .center
            valueLabel.countFrom(control!.oldValue, to: control!.value, withDuration: 1.5)
            valueLabel.numberOfLines   = 1
            valueLabel.textColor       = ctrl.fgdColor
            valueLabel.backgroundColor = UIColor.clear
            valueLabel.font            = mediumFont
            valueLabel.center          = CGPoint(x: size * 0.5, y: ctrl.graphicContainerVisible ? (y + chartSize * 0.5 - chartSize * 0.22) : (y + chartSize * 0.5 + chartSize * 0.22))
            valueLabel.setNeedsDisplay()
        }
        UIGraphicsPopContext()
    }
}

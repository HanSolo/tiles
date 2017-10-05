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
    
    
    // ******************** Constructors **************
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
    
    
    // ******************** Methods *******************
    override func update(cmd: String) {        
        guard let tile = control else { return }
        
        if (cmd == Helper.INIT) {
            tile.addSubview(percentageValueLabel)
            tile.addSubview(valueLabel)
            tile.addTileEventListener(listener: self)
        } else if (cmd == Helper.REDRAW) {
            setNeedsDisplay()
        }
    }
    override func update<T>(prop: String, value: T) {
        guard let tile = control else { return }
        
        if (prop == "value") {
            percentageValueLabel.countFrom((tile.oldValue / tile.range * 100.0), to: (tile.value / tile.range * 100.0), withDuration: tile.animationDuration)
            valueLabel.countFrom(tile.oldValue, to: tile.value, withDuration: tile.animationDuration)
            animateBar(duration: tile.animationDuration, tile:tile)
        }
    } 
    
    func animateBar(duration: TimeInterval, tile: Tile) {        
        let animation            = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue      = (tile.oldValue / tile.range) // 0 -> no circle
        animation.toValue        = (tile.value / tile.range)    // 1 -> full circle
        animation.duration       = duration
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        barLayer.strokeEnd       = (tile.value / tile.range) // end value after animation
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
                     frame   : CGRect(x: size * 0.05, y: size * 0.89, width: width - size * 0.1, height: size * 0.08),
                     fgdColor: tile.fgdColor,
                     bkgColor: tile.bkgColor,
                     radius  : 0,
                     align   : tile.textAlignment)
        } else {
            tile.textLabel.textColor = UIColor.clear
        }
        
        let chartWidth  = width * 0.9
        let chartHeight = tile.textVisible ? (size * 0.72) : (size * 0.795)
        chartSize       = chartWidth < chartHeight ? chartWidth : chartHeight
        y = size * 0.15 + (size * (tile.textVisible ? 0.75 : 0.85) - chartSize) * 0.5
        
        let barBackground = UIBezierPath(arcCenter : CGPoint(x: centerX, y: y + chartSize * 0.5),
                                         radius    : chartSize * 0.4135,
                                         startAngle: 0,
                                         endAngle  : .pi * 2.0,
                                         clockwise : true)
        barBackground.lineWidth = chartSize * 0.1
        tile.barBackgroundColor.brighter(by: 7)?.setStroke()
        barBackground.stroke()
        
        bar = UIBezierPath(arcCenter : CGPoint(x: centerX, y: y + chartSize * 0.5),
                           radius    : chartSize * 0.4135,
                           startAngle: -startAngle,
                           endAngle  : -startAngle + .pi * 2.0,
                           clockwise : true)
        barLayer.path        = bar.cgPath
        barLayer.strokeColor = tile.barColor.cgColor
        barLayer.lineWidth   = chartSize * 0.1
        
        let formatString       = "%.\(tile.decimals)f"
        
        let unitFont           = UIFont.init(name: "Lato-Regular", size: chartSize * (tile.graphicContainerVisible ? 0.035 : 0.04))
        let percentageUnitFont = UIFont.init(name: "Lato-Regular", size: chartSize * (tile.graphicContainerVisible ? 0.07 : 0.08))
        let mediumFont         = UIFont.init(name: "Lato-Regular", size: chartSize * (tile.graphicContainerVisible ? 0.075 : 0.1))
        let bigFont            = UIFont.init(name: "Lato-Regular", size: chartSize * (tile.graphicContainerVisible ? 0.15 : 0.2))
        
        percentageValueLabel.frame = CGRect(x     : size * 0.05,
                                            y     : centerY - size * 0.35,
                                            width : size * 0.9,
                                            height: size * 0.288)
        setAttributedFormatBlock(label       : percentageValueLabel,
                                 valueFont   : bigFont!,
                                 formatString: formatString,
                                 valueColor  : tile.valueColor,
                                 unit        : "%",
                                 unitFont    : percentageUnitFont!,
                                 unitColor   : tile.unitColor)
        percentageValueLabel.textAlignment   = .center
        percentageValueLabel.numberOfLines   = 1
        percentageValueLabel.backgroundColor = UIColor.clear
        percentageValueLabel.center          = CGPoint(x: size * 0.5, y: y + chartSize * 0.5)
        percentageValueLabel.setNeedsDisplay()
        percentageValueLabel.countFrom((tile.oldValue / tile.range * 100.0), to: (tile.value / tile.range * 100.0), withDuration: tile.animationDuration)
        
        valueLabel.frame = CGRect(x: 0, y: 0, width: size * 0.9, height:size * 0.12)
        setAttributedFormatBlock(label       : valueLabel,
                                 valueFont   : mediumFont!,
                                 formatString: formatString,
                                 valueColor  : tile.valueColor,
                                 unit        : tile.unit,
                                 unitFont    : unitFont!,
                                 unitColor   : tile.unitColor)
        valueLabel.textAlignment   = .center
        valueLabel.numberOfLines   = 1
        valueLabel.backgroundColor = UIColor.clear
        valueLabel.center          = CGPoint(x: size * 0.5,
                                             y: tile.graphicContainerVisible ? (y + chartSize * 0.5 - chartSize * 0.22) : (y + chartSize * 0.5 + chartSize * 0.22))
        valueLabel.setNeedsDisplay()
        valueLabel.countFrom(tile.oldValue, to: tile.value, withDuration: tile.animationDuration)
        
        UIGraphicsPopContext()
    }
}

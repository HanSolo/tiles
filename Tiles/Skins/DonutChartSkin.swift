//
//  DonutChartSkin.swift
//  Tiles
//
//  Created by Gerrit Grunwald on 08.10.17.
//  Copyright © 2017 Gerrit Grunwald. All rights reserved.
//

import UIKit

class DonutChartSkin: Skin, ChartDataEventListener {
    private var chartLayer : ChartLayer?
    
    
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
        guard let tile = control else { return }
        
        if (cmd == Helper.INIT) {
            chartLayer                = ChartLayer(tile: tile)
            chartLayer!.contentsScale = UIScreen.main.scale
            tile.layer.addSublayer(chartLayer!)
            chartLayer!.setNeedsDisplay()
        } else if (cmd == Helper.REDRAW) {
            setNeedsDisplay()
        } else if (cmd == Helper.UPDATE) {
            tile.chartDataList.forEach { chartData in
                chartData.addChartDataEventListener(listener: self)
            }
        }
    }
    override func update<T>(prop: String, value: T) {
        //guard let tile = control else { return }
        if (prop == "value") {
            
        }
    }
    
    override func layoutSublayers() {
        super.layoutSublayers()
        chartLayer!.frame = bounds
    }
    
    func onChartDataEvent(event: ChartDataEvent) {
        chartLayer!.setNeedsDisplay()        
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
        
        UIGraphicsPopContext()
    }
    
    
    // ******************** Inner Classes *************
    private class ChartLayer: CALayer {
        private var tile     : Tile
        private var sumLabel = UILabel()
        
        // ******************** Constructors **************
        init(tile: Tile) {
            self.tile = tile
            super.init()
            
            addSublayer(sumLabel.layer)
        }
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        
        // ******************** Redraw ********************
        override func draw(in ctx: CGContext) {
            UIGraphicsPushContext(ctx)
            
            let size        = tile.frame.width < tile.frame.height ? tile.frame.width : tile.frame.height
            let width       = tile.frame.width - size * 0.1
            let height      = tile.textVisible ? tile.frame.height - size * 0.28 : tile.frame.height - size * 0.205
            let chartSize   = width < height ? width : height
            let innerRadius = chartSize * 0.275
            let outerRadius = chartSize * 0.4
            let sum         = tile.chartDataList.reduce(0) { $0 + $1.value }
            let stepSize    = CGFloat(360.0 / sum)
            var startAngle  = Helper.toRadians(deg: CGFloat(-90.0))
            var angle       = CGFloat(0.0)
            let barWidth    = chartSize * 0.1
            let center      = CGPoint(x: tile.frame.width * 0.5, y: tile.frame.height * 0.5)
            let radius      = CGFloat(chartSize * 0.4)
            let smallFont   = UIFont.init(name: "Lato-Regular", size: barWidth * 0.5)
            
            if (tile.valueVisible) {
                ctx.setFillColor(tile.fgdColor.cgColor)
                let valueFont  = UIFont.init(name: "Lato-Regular", size: chartSize * 0.15)
                
                // Sum
                sumLabel.frame = CGRect(x: center.x - chartSize * 0.5, y: center.y - chartSize * 0.5, width: chartSize, height: chartSize)
                drawTextWithFormat(label   : sumLabel,
                                   font    : valueFont!,
                                   value   : sum,
                                   fgdColor: tile.fgdColor,
                                   bkgColor: UIColor.clear,
                                   radius  : 0,
                                   format  : "%.\(tile.decimals)f",
                                   align   : NSTextAlignment.center,
                                   center  : center)
            }
            
            ctx.setLineCap(CGLineCap.butt)
            ctx.setFillColor(UIColor.clear.cgColor)
            ctx.setLineWidth(barWidth)
            
            for data in tile.chartDataList {
                let value = data.value
                startAngle += angle
                angle = Helper.toRadians(deg: value * stepSize)
                
                ctx.setStrokeColor(data.color.cgColor)
                ctx.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: CGFloat(startAngle + angle), clockwise: false)
                ctx.strokePath()
                
                let radValue = -startAngle - angle * 0.5
                let cosValue = cos(radValue)
                let sinValue = sin(radValue)
                
                // Percentage
                let percentageString = String(format: "%.0f%%", (value / sum * 100.0))
                var textSize         = smallFont!.sizeOfString(string: percentageString, constrainedToWidth: Double(size))
                var x                = innerRadius * cosValue - textSize.width * 0.5
                var y                = -innerRadius * sinValue - textSize.height * 0.5
                let percentageText   = NSMutableAttributedString(
                    string    : percentageString,
                    attributes: [ NSAttributedStringKey.font           : smallFont!,
                                  NSAttributedStringKey.foregroundColor: tile.fgdColor ])
                percentageText.draw(at: CGPoint(x: center.x + x, y: center.y + y))
                
                // Value
                let valueString = String(format: "%.0f", value)
                textSize        = smallFont!.sizeOfString(string: valueString, constrainedToWidth: Double(size))
                x               = outerRadius * cosValue - textSize.width * 0.5
                y               = -outerRadius * sinValue - textSize.height * 0.5
                let valueText   = NSMutableAttributedString(
                    string    : String(format: "%.0f", value),
                    attributes: [ NSAttributedStringKey.font           : smallFont!,
                                  NSAttributedStringKey.foregroundColor: tile.bkgColor ])
                valueText.draw(at: CGPoint(x: center.x + x, y: center.y + y))
            }
            
            UIGraphicsPopContext()
        }
        
        func drawTextWithFormat(label : UILabel, font: UIFont, value: CGFloat, fgdColor: UIColor, bkgColor: UIColor, radius: CGFloat, format: String, align: NSTextAlignment, center: CGPoint) {
            label.textAlignment       = align
            label.text                = String(format: format, value)
            label.numberOfLines       = 1
            label.font                = font
            label.sizeToFit()
            label.textColor           = fgdColor
            label.backgroundColor     = bkgColor
            label.layer.masksToBounds = true
            label.layer.cornerRadius  = radius
            label.center              = center
            label.setNeedsDisplay()
        }
    }
}

//
//  SparkLineSkin.swift
//  Tiles
//
//  Created by Gerrit Grunwald on 09.10.17.
//  Copyright © 2017 Gerrit Grunwald. All rights reserved.
//

import UIKit

class SparkLineSkin: Skin, ChartDataEventListener {
    private let valueLabel = AnimLabel()
    private var chartLayer : ChartLayer?
    
    
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
        guard let tile = control else { return }
        
        if (cmd == Helper.INIT) {
            tile.addSubview(valueLabel)
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
        } else if (cmd == Helper.AVERAGING) {
            chartLayer!.averaging()
        }
    }
    override func update<T>(prop: String, value: T) {
        guard let tile = control else { return }
        if (prop == "value") {
            valueLabel.countFrom(tile.oldValue, to: tile.value, withDuration: tile.animationDuration)
            
            if (!tile.averagingEnabled) { tile.averagingEnabled = true }
            let clampedValue = Helper.clamp(min: tile.minValue, max: tile.maxValue, value: value as! CGFloat)
            chartLayer!.addData(value: clampedValue)
            chartLayer!.handleCurrentValue(value: clampedValue)
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
        let unitFont   = UIFont.init(name: "Lato-Regular", size: size * 0.12)
        let bigFont    = UIFont.init(name: "Lato-Regular", size: size * 0.24)
        
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
        
        // Value
        valueLabel.frame = CGRect(x     : size * 0.05,
                                  y     : size * 0.15,
                                  width : width - size * 0.1,
                                  height: size * 0.288)
        setAttributedFormatBlock(label       : valueLabel,
                                 valueFont   : bigFont!,
                                 formatString: "%.\(tile.decimals)f",
            valueColor  : tile.valueColor,
            unit        : tile.unit,
            unitFont    : unitFont!,
            unitColor   : tile.unitColor)
        valueLabel.textAlignment   = .right
        valueLabel.numberOfLines   = 1
        valueLabel.backgroundColor = UIColor.clear
        valueLabel.setNeedsDisplay()
        valueLabel.countFrom(tile.oldValue, to: tile.value, withDuration: tile.animationDuration)
        
        UIGraphicsPopContext()
    }
    
    
    // ******************** Inner Classes *************
    private class ChartLayer: CALayer {        
        private let MONTH                    = 2592000.0
        private let DAY                      = 86400.0
        private let HOUR                     = 3600.0
        private let MINUTE                   = 60.0
        private var tile         : Tile
        private var dataList     : [CGFloat] = [] { didSet { /*  */ }}
        private var noOfDataPoints           = 0
        private var timeFormatter            = DateFormatter()
        private var stdDeviation             = CGFloat(0.0)
        private var stdDeviationArea         = CGRect()
        private var minValue                 = CGFloat(0.0)
        private var maxValue                 = CGFloat(0.0)
        private var high                     = CGFloat(0.0)
        private var low                      = CGFloat(0.0)
        private var range                    = CGFloat(0.0)
        private var graphBounds              = CGRect()
        private var sparkLine                = UIBezierPath()
        private var dot                      = UIBezierPath()
        private var dotCenter                = CGPoint()
        private var niceScaleY               = NiceScale()
        private var horizontalTickLines      = Array(repeating: Line(), count: 5) //:[Line] = []
        private var horizontalLineOffset     = CGFloat(0.0)
        private var tickLabelFontSize        = CGFloat(0.0)
        private var tickLineColor            = Helper.GRAY
        private var averageLine              = Line()
        private var gradient                 : LinearGradient?
        private var gradientLookup           : GradientLookup?
        private var averageText              = ""
        private var valueText                = ""
        private var highText                 = ""
        private var lowText                  = ""
        private var timespanText             = ""
        private var text                     = ""
        private var formatString             = ""
        
        
        // ******************** Constructors **************
        init(tile: Tile) {
            self.tile = tile
            super.init()
            
            noOfDataPoints = tile.averagingPeriod
            minValue       = CGFloat(tile.minValue)
            maxValue       = CGFloat(tile.maxValue)
            for i in 0...4 {
                horizontalTickLines[i].strokeColor = UIColor.clear
                horizontalTickLines[i].dashArray.append(1.0)
                horizontalTickLines[i].dashArray.append(2.0)
            }
            tickLineColor            = tile.chartGridColor.withAlphaComponent(0.5)
            formatString             = "%.\(tile.decimals)f"
            gradientLookup           = GradientLookup(stops: tile.gradientStops)
            timeFormatter.dateFormat = "HH:mm"
        }
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        
        // ******************** Methods *******************
        func handleCurrentValue(value: CGFloat) {
            low  = Statistics.getMin(data: dataList)!
            high = Statistics.getMax(data: dataList)!
            if (Helper.equals(a: low, b: high)) {
                low  = minValue
                high = maxValue
            }
            range = high - low
            
            let minX  = graphBounds.minX
            let maxX  = graphBounds.maxX
            let minY  = graphBounds.minY
            let maxY  = graphBounds.maxY
            let stepX = graphBounds.width / CGFloat(noOfDataPoints - 1)
            let stepY = graphBounds.height / CGFloat(range)
            
            niceScaleY.setMinMax(min: low, max: high)
            var lineCountY       = 0
            var tickLabelOffsetY = CGFloat(1)
            let tickSpacingY     = niceScaleY.getTickSpacing()
            let tickStepY        = tickSpacingY * stepY
            var tickStartY       = maxY - (tickSpacingY - CGFloat(low)) * stepY
            if (tickSpacingY < CGFloat(low)) {
                tickLabelOffsetY = (CGFloat(low) / tickSpacingY) + 1
                tickStartY       = maxY - (tickLabelOffsetY * tickSpacingY - CGFloat(low)) * stepY
            }
            
            horizontalLineOffset = 0.0
            if (tickLabelFontSize < 6) { horizontalLineOffset = 0.0 }
            
            var y = tickStartY
            while round(y) > minY {
                /*
                Text label = tickLabelsY.get(lineCountY);
                label.setText(String.format(locale, "%.0f", (tickSpacingY * (lineCountY + tickLabelOffsetY))));
                label.setY(y + graphBounds.getHeight() * 0.03);
                label.setFill(tickLineColor);
                horizontalLineOffset = max(label.getLayoutBounds().getWidth(), horizontalLineOffset);
                */
                
                let line = Line(x1: minX, y1: y, x2: maxX - CGFloat(tickLabelFontSize < 6 ? 0.0 : horizontalLineOffset), y2: y)
                line.strokeColor                = tickLineColor
                line.dashArray                  = [1.0, 2.0]
                horizontalTickLines[lineCountY] = line
                lineCountY += 1
                if (lineCountY > 4) { break }
                lineCountY = Helper.clamp(min: 0, max: 4, value: lineCountY);
                y -= tickStepY
            }
            
            //tickLabelsY.forEach { label in label.x = maxX - label.bounds.width }
            
            if (!dataList.isEmpty) {
                if (tile.smoothing && dataList.count >= 4) {
                    smooth(dataList: dataList)
                } else {
                    sparkLine.removeAllPoints()
                    sparkLine.move(to: CGPoint(x: minX, y: maxY - abs(low - dataList[0]) * stepY))
                    for i in 1..<noOfDataPoints-1 {
                        sparkLine.addLine(to: CGPoint(x: minX + CGFloat(i) * stepX, y: maxY - abs(low - dataList[i]) * stepY))                        
                    }
                    sparkLine.addLine(to: CGPoint(x: maxX, y: maxY - abs(low - dataList[noOfDataPoints - 1]) * stepY))
                    dotCenter.x = maxX
                    dotCenter.y = maxY - abs(low - dataList[noOfDataPoints - 1]) * stepY
                    
                    if (tile.strokeWithGradient) {
                        setupGradient()
                    }
                }
                
                let average        = tile.movingAverage.getAverage()
                let averageY       = Helper.clamp(min: minY, max: maxY, value: maxY - abs(low - average) * stepY)
                
                averageLine.from.x = minX
                averageLine.from.y = averageY
                averageLine.to.x   = maxX
                averageLine.to.y   = averageY
                
                stdDeviationArea   = CGRect(x: graphBounds.minX, y: averageLine.from.y - (stdDeviation * 0.5 * stepY), width: graphBounds.width, height: stdDeviation * stepY)
                
                averageText = String(format: formatString, average)
            }
            
            valueText = String(format: formatString, value)
            highText  = String(format: formatString, high)
            lowText   = String(format: formatString, low)
            
            setNeedsDisplay()
        }
        
        func averaging() {
            noOfDataPoints = tile.averagingPeriod
            if (noOfDataPoints < 4) { return }
            for _ in 0..<noOfDataPoints { dataList.append(minValue) }
            setNeedsDisplay()
        }
        
        func addData(value: CGFloat) {
            if (dataList.isEmpty) { for _ in 0..<noOfDataPoints { dataList.append(value) } }
            if (dataList.count <= noOfDataPoints) {
                dataList.rotate(positions: 1)
                dataList[noOfDataPoints - 1] = value
            } else {
                dataList.append(value)
            }
            stdDeviation = Statistics.getStdDev(data: dataList)
        }
        
        func setupGradient() {
            let loFactor = (low - minValue) / tile.range
            let hiFactor = (high - minValue) / tile.range
            let loStop   = Stop(fraction: loFactor, color: (gradientLookup?.colorAt(position: loFactor))!)
            let hiStop   = Stop(fraction: hiFactor, color: (gradientLookup?.colorAt(position: hiFactor))!)
            gradient     = LinearGradient(from: CGPoint(x: CGFloat(0.0), y: graphBounds.minY + graphBounds.height), to: CGPoint(x: 0, y: graphBounds.minY), stops: loStop, hiStop)
        }
        
        func createTimeSpanText() -> String {
            let timeSpan = tile.movingAverage.getTimeSpan()
            var timeSpanString = tile.movingAverage.isFilling() ? "\u{22a2} " : "\u{2190} "
            if (timeSpan > MONTH) { // 1 Month (30 days)
                let months = (Int)(timeSpan / MONTH)
                let days   = timeSpan.truncatingRemainder(dividingBy: MONTH)
                timeSpanString += "\(months)M\(String(format: "%.0f", days))d \u{2192}"
            } else if (timeSpan > DAY) { // 1 Day
                let days  = (timeSpan / DAY)
                let hours = (timeSpan - (days * DAY)) / HOUR
                timeSpanString += "\(days)d\(String(format:"%.0f", hours))h \u{2192}"
            } else if (timeSpan > HOUR) { // 1 Hour
                let hours   = (timeSpan / HOUR)
                let minutes = (timeSpan - (hours * HOUR)) / MINUTE
                timeSpanString += "\(hours)h\(String(format:"%.0f", minutes))m \u{2192}"
            } else if (timeSpan > MINUTE) { // 1 Minute
                let minutes = (timeSpan / MINUTE)
                let seconds = (timeSpan - (minutes * MINUTE))
                timeSpanString += "\(minutes)m\(String(format:"%.0f", seconds))s \u{2192}"
            } else {
                let seconds = timeSpan
                timeSpanString += "\(String(format: "%.0f", seconds))s \u{2192}"
            }
            return timeSpanString
        }
        
        func smooth(dataList: [CGFloat]) {
            let size           = dataList.count
            
            var x   :[CGFloat] = Array(repeating: 0.0, count: size)
            var y   :[CGFloat] = Array(repeating: 0.0, count: size)
            
            low  = Statistics.getMin(data: dataList)!
            high = Statistics.getMax(data: dataList)!
            if (Helper.equals(a: low, b: high)) {
                low  = minValue
                high = maxValue
            }
            range = high - low;
            
            let minX  = graphBounds.minX
            let maxX  = graphBounds.maxX
            let minY  = graphBounds.minY
            let maxY  = graphBounds.maxY
            let stepX = graphBounds.width / CGFloat(noOfDataPoints - 1)
            let stepY = graphBounds.height / CGFloat(range)
            
            for i in 0..<size {
                x[i] = minX + CGFloat(i) * stepX
                y[i] = maxY - CGFloat(abs(low - dataList[i])) * stepY
            }
            
            var px = computeControlPoints(k: x)
            var py = computeControlPoints(k: y)
            
            sparkLine.removeAllPoints()
            for i in 0..<size-1 {
                sparkLine.move(to: CGPoint(x: x[i], y: y[i]))
                sparkLine.addCurve(to: CGPoint(x: x[i + 1], y: y[i + 1]), controlPoint1: CGPoint(x: px.0[i], y: py.0[i]), controlPoint2: CGPoint(x: px.1[i], y: py.1[i]))
            }
            
            dotCenter.x = maxX
            dotCenter.y = y[size - 1]
        }
        
        func computeControlPoints(k: [CGFloat]) -> ([CGFloat], [CGFloat]) {
            let n              = k.count - 1
            var p1 : [CGFloat] = Array(repeating: 0.0, count: n)
            var p2 : [CGFloat] = Array(repeating: 0.0, count: n)
            
            /*rhs vector*/
            var a : [CGFloat] = Array(repeating: 0.0, count: n)
            var b : [CGFloat] = Array(repeating: 0.0, count: n)
            var c : [CGFloat] = Array(repeating: 0.0, count: n)
            var r : [CGFloat] = Array(repeating: 0.0, count: n)
            
            /*left most segment*/
            a[0] = 0.0
            b[0] = 2.0
            c[0] = 1.0
            r[0] = k[0] + 2.0 * k[1]
            
            /*internal segments*/
            for i in 1..<n-1 {
                a[i] = 1.0
                b[i] = 4.0
                c[i] = 1.0
                r[i] = 4.0 * k[i] + 2.0 * k[i + 1]
            }
            
            /*right segment*/
            a[n-1] = 2.0
            b[n-1] = 7.0
            c[n-1] = 0.0
            r[n-1] = 8.0 * k[n - 1] + k[n]
            
            /*solves Ax = b with the Thomas algorithm*/
            for i in 1..<n {
                let m = a[i] / b[i - 1]
                b[i] = b[i] - m * c[i - 1]
                r[i] = r[i] - m * r[i - 1]
            }
            
            p1[n-1] = r[n-1] / b[n-1]
            
            var i = n-2
            while i >= 0 {
                p1[i] = (r[i] - c[i] * p1[i + 1]) / b[i]
                i -= 1
            }
            
            for i in 0..<n-1 { p2[i] = 2.0 * k[i + 1] - p1[i + 1] }
            p2[n - 1] = 0.5 * (k[n] + p1[n - 1]);
            
            return (p1, p2)
        }
        
        
        // ******************** Redraw ********************
        override func draw(in ctx: CGContext) {
            UIGraphicsPushContext(ctx)
            
            let size          = tile.frame.width < tile.frame.height ? tile.frame.width : tile.frame.height
            let width         = tile.frame.width
            let height        = tile.frame.height
            let offsetY       = size * 0.45
    
            tickLabelFontSize = size * 0.1
            let tickLabelFont = UIFont.init(name: "Lato-Regular", size: tickLabelFontSize)
            
            graphBounds = CGRect(x: size * 0.05, y: size * 0.05, width: width - size * 0.1, height: height - size * 0.61)
            
            ctx.saveGState()
            ctx.setLineWidth(0.5)
            ctx.translateBy(x: 0, y: offsetY)
            ctx.setStrokeColor(horizontalTickLines[0].strokeColor.cgColor)
            ctx.setLineDash(phase: 0, lengths: horizontalTickLines[0].dashArray)
            for line in horizontalTickLines {
                ctx.move(to: line.from)
                ctx.addLine(to: line.to)
                ctx.strokePath()
            }
            ctx.restoreGState()
            
            
            let averagingPeriod = tile.averagingPeriod
            var dotRadius: CGFloat
            if (averagingPeriod < 250) {
                ctx.setLineWidth(size * 0.01)
                dotRadius = size * 0.014
            } else if (averagingPeriod < 500) {
                ctx.setLineWidth(size * 0.0075)
                dotRadius = size * 0.0105
            } else {
                ctx.setLineWidth(size * 0.005)
                dotRadius = size * 0.007
            }
            
            if (tile.strokeWithGradient) { setupGradient() }
            
            sparkLine.apply(CGAffineTransform(translationX: 0, y: offsetY))
            ctx.addPath(sparkLine.cgPath)
            ctx.setStrokeColor(tile.barColor.cgColor)
            ctx.strokePath()
            
            dotCenter.y += offsetY
            ctx.addPath(UIBezierPath(arcCenter: dotCenter, radius: dotRadius, startAngle: 0, endAngle: .pi * 2, clockwise: true).cgPath)
            ctx.setFillColor(tile.barColor.cgColor)
            ctx.fillPath()
            
            /*
             private var averageText              = ""
             private var valueText                = ""
             private var highText                 = ""
             private var lowText                  = ""
             private var timespanText             = ""
             private var text                     = ""
            */
            if (tile.textVisible) {
                text = tile.text
            } else {
                timespanText = createTimeSpanText()
                if (tile.movingAverage.getTimeSpan() > 0) {
                    text = timeFormatter.string(from: (tile.movingAverage.getLastEntry()?.timestamp)!)
                }
            }
            let smallFont = UIFont.init(name: "Lato-Regular", size: size * 0.06)
            if (!tile.textVisible) {
                //let averageLabel = averageText
                //var textSize     = smallFont!.sizeOfString(string: averageText, constrainedToWidth: Double(width - size * 0.7))
                //var x            = outerRadius * cosValue - textSize.width * 0.5
                //var y            = -outerRadius * sinValue - textSize.height * 0.5
                let textSize      = smallFont!.sizeOfString(string: averageText, constrainedToWidth: Double(width - size * 0.25))
                let timespanLabel = NSMutableAttributedString(
                    string    : timespanText,
                    attributes: [ NSAttributedStringKey.font           : smallFont!,
                                  NSAttributedStringKey.foregroundColor: tile.fgdColor ])
                timespanLabel.draw(at: CGPoint(x: (width - textSize.width) * 0.5 - size * 0.05, y: height - size * 0.05 - (textSize.height * 0.5)))
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

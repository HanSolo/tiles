//
//  SmoothAreaTileSkin.swift
//  Tiles
//
//  Created by Gerrit Grunwald on 02.10.17.
//  Copyright © 2017 Gerrit Grunwald. All rights reserved.
//

import UIKit

class SmoothAreaTileSkin: Skin {
    let valueLabel = AnimLabel()
    
    var dataSize  : Int     = 0
    var maxValue  : CGFloat = 0
    var hStepSize : CGFloat = 0
    var vStepSize : CGFloat = 0
    
    let fillLayer     = CAShapeLayer()
    var fillPath      = UIBezierPath()
    let strokeLayer   = CAShapeLayer()
    var strokePath    = UIBezierPath()
    //let gradientLayer = CAGradientLayer()
    
    
    // ******************** Constructors ********************
    override init() {
        super.init()
        valueLabel.method        = .easeInOut
        valueLabel.format        = "%.1f"
        valueLabel.textAlignment = .right
        
        fillPath                 = UIBezierPath()
        strokePath               = UIBezierPath()
        
        fillLayer.path          = fillPath.cgPath
        fillLayer.strokeColor   = UIColor.clear.cgColor
        fillLayer.fillColor     = Helper.BLUE.cgColor
        addSublayer(fillLayer)
        
        //addSublayer(gradientLayer)
        
        strokeLayer.path          = strokePath.cgPath
        strokeLayer.strokeColor   = Helper.BLUE.cgColor
        strokeLayer.fillColor     = UIColor.clear.cgColor
        addSublayer(strokeLayer)
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
            tile.textVisible = false
            tile.addSubview(valueLabel)
        } else if (cmd == Helper.REDRAW) {
            setNeedsDisplay()
        } else if (cmd == Helper.UPDATE) {
            tile.chartDataList.forEach { chartData in chartData.eventBus.unsubscribe(eventNameToRemoveOrNil: Helper.UPDATE) }
            tile.chartDataList.forEach { chartData in
                chartData.eventBus.subscribeTo(eventName: Helper.UPDATE, action: self.animateChart)
            }
            setNeedsDisplay()
        }
    }
    override func update<T>(prop: String, value: T) {
        guard let tile = control else { return }
        
        if (prop == "value") {
            valueLabel.countFrom(tile.oldValue, to: tile.value, withDuration: tile.animationDuration)
        }
    }
    
    func handleSingleChartData(chartData : Any?) {
        if let data = chartData as? ChartData {
            print("update data \(data.name): \(data.value)")
        }
    }
    
    func getPaths(oldValues : Bool) -> (UIBezierPath, UIBezierPath) {
        guard let tile = control else { return (UIBezierPath(), UIBezierPath()) }
        var data :[ChartData] = tile.chartDataList
        dataSize = data.count
        if (dataSize == 0) { return (UIBezierPath(), UIBezierPath()) }
        
        if (!oldValues) {
            if let lastDataEntryValue = data.last?.value { tile.value = lastDataEntryValue }
        }
        
        maxValue  =  CGFloat(data.map { oldValues ? $0.oldValue : $0.value }.max()!)
        hStepSize = width / CGFloat(dataSize)
        vStepSize = (height * 0.5) / maxValue
        var fillElements   : [CGPoint] = []
        var strokeElements : [CGPoint] = []
        fillElements.append(CGPoint(x: 0, y: height))
        strokeElements.append(CGPoint(x: 0, y: height - (oldValues ? data[0].oldValue : data[0].value) * vStepSize))
        
        if (oldValues) {
            for i in 0..<dataSize {
                fillElements.append(CGPoint(x: CGFloat(i + 1) * hStepSize, y: height - data[i].oldValue * vStepSize))
                strokeElements.append(CGPoint(x: CGFloat(i + 1) * hStepSize, y: height - data[i].oldValue * vStepSize))
            }
        } else {
            for i in 0..<dataSize {
                fillElements.append(CGPoint(x: CGFloat(i + 1) * hStepSize, y: height - data[i].value * vStepSize))
                strokeElements.append(CGPoint(x: CGFloat(i + 1) * hStepSize, y: height - data[i].value * vStepSize))
            }
        }
        
        fillElements.append(CGPoint(x: width, y: height))
        return smooth(strokeElements: &strokeElements, fillElements: &fillElements)
    }
    
    func smooth(strokeElements : inout [CGPoint], fillElements : inout [CGPoint]) -> (UIBezierPath, UIBezierPath) {
        if (fillElements.isEmpty) { return (UIBezierPath(), UIBezierPath())}
        // next we need to know the zero Y value
        let zeroY = fillElements[0].y
        
        // now rebuild elements
        let result : ([CGPoint], [CGPoint]) = calcCurveControlPoints(dataPoints: strokeElements)
        var firstControlPoints  = result.0
        var secondControlPoints = result.1
        
        // clear both paths
        let strokePath : UIBezierPath = UIBezierPath()
        let fillPath   : UIBezierPath = UIBezierPath()
        
        // start both paths
        strokePath.move(to: CGPoint(x: strokeElements[0].x, y: strokeElements[0].y))
        fillPath.move(to: CGPoint(x: strokeElements[0].x, y: zeroY))
        fillPath.addLine(to: CGPoint(x: strokeElements[0].x, y: strokeElements[0].y))
        
        // add curves
        for i in 2..<strokeElements.count {
            let ci = i - 1
            let point         = CGPoint(x: strokeElements[i].x, y: strokeElements[i].y)
            let controlPoint1 = CGPoint(x: firstControlPoints[ci].x, y: firstControlPoints[ci].y)
            let controlPoint2 = CGPoint(x: secondControlPoints[ci].x, y: secondControlPoints[ci].y)
            strokePath.addCurve(to: point, controlPoint1: controlPoint1, controlPoint2: controlPoint2)
            fillPath.addCurve(to: point, controlPoint1: controlPoint1, controlPoint2: controlPoint2)
        }
        // end the paths
        fillPath.addLine(to: CGPoint(x: strokeElements[strokeElements.count - 1].x, y: zeroY))
        fillPath.close()
        return (strokePath, fillPath)
    }
    
    func calcCurveControlPoints(dataPoints : [CGPoint]) -> ([CGPoint], [CGPoint]) {
        var firstControlPoints  : [CGPoint] = []
        var secondControlPoints : [CGPoint] = []
        let n = dataPoints.count - 1;
        if (n == 1) { // Special case: Bezier curve should be a straight line.
            firstControlPoints.insert(CGPoint(x: (2 * dataPoints[0].x + dataPoints[1].x) / 3, y: (2 * dataPoints[0].y + dataPoints[1].y) / 3), at: 0)
            secondControlPoints.insert(CGPoint(x: (2 * firstControlPoints[0].x - dataPoints[0].x), y: 2 * firstControlPoints[0].y - dataPoints[0].y), at: 0)
            return (firstControlPoints, secondControlPoints)
        }
    
        // Calculate first Bezier control points
        // Right hand side vector
        var rhs : [CGFloat] = []
    
        // Set right hand side X values
        rhs.insert(CGFloat(dataPoints[0].x + 2 * dataPoints[1].x), at: 0)
        for i in 1..<n-1 {
            rhs.insert(CGFloat(4 * dataPoints[i].x + 2 * dataPoints[i + 1].x), at: i)
        }
        rhs.insert(CGFloat((8 * dataPoints[n - 1].x + dataPoints[n].x) / 2.0), at: n-1)
        
        // Get first control points X-values
        var x = getFirstControlPoints(rhs: rhs)
    
        rhs.removeAll()
        
        // Set right hand side Y values
        rhs.insert(CGFloat(dataPoints[0].y + 2 * dataPoints[1].y), at: 0)
        for i in 1..<n-1 {
            rhs.insert(CGFloat(4 * dataPoints[i].y + 2 * dataPoints[i + 1].y), at: i)
        }
        rhs.insert(CGFloat((8 * dataPoints[n - 1].y + dataPoints[n].y) / 2.0), at: n-1)
        
        // Get first control points Y-values
        var y = getFirstControlPoints(rhs: rhs)
    
        // Fill output arrays.
        firstControlPoints.removeAll()
        secondControlPoints.removeAll()
        
        for i in 0..<n {
            firstControlPoints.insert(CGPoint(x: x[i], y: y[i]), at: i)
            if (i < n - 1) {
                secondControlPoints.insert(CGPoint(x: 2 * dataPoints[i + 1].x - x[i + 1], y: 2 * dataPoints[i + 1].y - y[i + 1]), at: i)
            } else {
                secondControlPoints.insert(CGPoint(x: (dataPoints[n].x + x[n - 1]) / 2, y: (dataPoints[n].y + y[n - 1]) / 2), at: i)
            }
        }
        return (firstControlPoints, secondControlPoints)
    }
    
    func getFirstControlPoints(rhs : [CGFloat]) -> [CGFloat] {
        let n               = rhs.count
        var x   : [CGFloat] = []
        var tmp : [CGFloat] = []
        var b               = CGFloat(2.0)
        
        tmp.append(CGFloat(-1)) // value not needed at location [0]
        x.insert(CGFloat(rhs[0] / b), at: 0)
        
        for i in 1..<n {
            tmp.insert(CGFloat(1 / b), at: i)
            b = (i < n - 1 ? 4.0 : 3.5) - tmp[i]
            x.insert(CGFloat((rhs[i] - x[i - 1]) / b), at: i)
        }
        for i in 1..<n {
            x[n - i - 1] -= tmp[n - i] * x[n - i]
        }
        return x
    }
    
    func animateChart() {
        guard let tile = control else { return }
        
        let oldPaths : (UIBezierPath, UIBezierPath) = getPaths(oldValues: true)
        let newPaths : (UIBezierPath, UIBezierPath) = getPaths(oldValues: false)
        
        fillPath.removeAllPoints()
        fillPath.append(oldPaths.1)
        
        let toFillPath                   = newPaths.1
        let animation0                   = CABasicAnimation(keyPath: "path")
        animation0.fromValue             = fillPath.cgPath
        animation0.toValue               = toFillPath.cgPath
        animation0.duration              = tile.animationDuration
        animation0.timingFunction        = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        animation0.fillMode              = kCAFillModeForwards
        animation0.isRemovedOnCompletion = false
        
        strokePath.removeAllPoints()
        strokePath.append(oldPaths.0)
        
        let toStrokePath                 = newPaths.0
        let animation1                   = CABasicAnimation(keyPath: "path")
        animation1.fromValue             = strokePath.cgPath
        animation1.toValue               = toStrokePath.cgPath
        animation1.duration              = tile.animationDuration
        animation1.timingFunction        = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        animation1.fillMode              = kCAFillModeForwards
        animation1.isRemovedOnCompletion = false
        
        fillLayer.add(animation0, forKey: "animateChart")
        strokeLayer.add(animation1, forKey: "animateChart")
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
        
        // Value
        let formatString = "%.\(tile.decimals)f"
        
        let unitFont     = UIFont.init(name: "Lato-Regular", size: size * 0.12)
        let bigFont      = UIFont.init(name: "Lato-Regular", size: size * 0.24)
        
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
        
        // Chart
        hStepSize = width / CGFloat(dataSize)
        vStepSize = (height * 0.5) / maxValue
        
        let newPaths : (UIBezierPath, UIBezierPath) = getPaths(oldValues: false) //getValuePaths()
        
        fillPath.removeAllPoints()
        fillPath.append(newPaths.1)
        fillLayer.frame         = CGRect(x: 0, y: 0, width: width, height: height)
        fillLayer.path          = fillPath.cgPath
        fillLayer.fillColor     = tile.barColor.withAlphaComponent(CGFloat(0.5)).cgColor
        
        /*
        let fillPathColor1       = tile.barColor.withAlphaComponent(CGFloat(0.7)).cgColor
        let fillPathColor2       = tile.barColor.withAlphaComponent(CGFloat(0.1)).cgColor
        let gradientLayer        = CAGradientLayer()
        gradientLayer.frame      = fillPath.bounds
        gradientLayer.colors     = [ fillPathColor1, fillPathColor2 ]
        gradientLayer.locations  = [ 0.0, 1.0 ]
        //gradientLayer.mask       = fillLayer
        fillLayer.addSublayer(gradientLayer)
        */
        
        strokePath.removeAllPoints()
        strokePath.append(newPaths.0)
        strokeLayer.frame       = CGRect(x: 0, y: 0, width: width, height: height)
        strokeLayer.lineWidth   = size * 0.02
        strokeLayer.lineCap     = kCALineCapSquare
        strokeLayer.lineJoin    = kCALineJoinMiter
        strokeLayer.path        = strokePath.cgPath
        strokeLayer.strokeColor = tile.barColor.cgColor
        
        let clippingPathFill   = UIBezierPath(roundedRect: bounds, cornerRadius: size * 0.025)
        let clippingLayerFill  = CAShapeLayer()
        clippingLayerFill.path = clippingPathFill.cgPath
        fillLayer.mask         = clippingLayerFill
        
        let clippingPathStroke   = UIBezierPath(roundedRect: bounds, cornerRadius: size * 0.025)
        let clippingLayerStroke  = CAShapeLayer()
        clippingLayerStroke.path = clippingPathStroke.cgPath
        strokeLayer.mask         = clippingLayerStroke
        
        UIGraphicsPopContext()
    }
}

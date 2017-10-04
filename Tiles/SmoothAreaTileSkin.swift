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
        if (cmd == Helper.INIT) {
            control!.textVisible = false
            control!.addSubview(valueLabel)
        } else if (cmd == Helper.REDRAW) {
            setNeedsDisplay()
        } else if (cmd == Helper.UPDATE) {
            control!.chartDataList.forEach { chartData in chartData.eventBus.unsubscribe(eventNameToRemoveOrNil: Helper.UPDATE) }
            control!.chartDataList.forEach { chartData in
                chartData.eventBus.subscribeTo(eventName: Helper.UPDATE, action: self.animateChart)
            }
            setNeedsDisplay()
        }
    }
    override func update<T>(prop: String, value: T) {
        if (prop == "value") {
            valueLabel.countFrom(control!.oldValue, to: control!.value, withDuration: control!.animationDuration)
        }
    }
    
    override func layoutSublayers() {
        super.layoutSublayers()
    }
    
    func handleSingleChartData(chartData : Any?) {
        if let data = chartData as? ChartData {
            print("update data \(data.name): \(data.value)")
        }
    }
    
    func getValuePaths() -> (UIBezierPath, UIBezierPath) {
        var data :[ChartData] = control!.chartDataList
        dataSize = data.count
        if (dataSize == 0) { return (UIBezierPath(), UIBezierPath()) }
        
        if let lastDataEntryValue = data.last?.value { control!.value = lastDataEntryValue }
        
        maxValue  =  CGFloat(data.map { $0.value }.max()!)
        hStepSize = width / CGFloat(dataSize)
        vStepSize = (height * 0.5) / maxValue
        var fillElements   : [CGPoint] = []
        var strokeElements : [CGPoint] = []
        fillElements.append(CGPoint(x: 0, y: height))
        strokeElements.append(CGPoint(x: 0, y: height - data[0].value * vStepSize))
        
        for i in 0..<dataSize {
            fillElements.append(CGPoint(x: CGFloat(i + 1) * hStepSize, y: height - data[i].value * vStepSize))
            strokeElements.append(CGPoint(x: CGFloat(i + 1) * hStepSize, y: height - data[i].value * vStepSize))
        }
        
        fillElements.append(CGPoint(x: width, y: height))
        return smooth(strokeElements: &strokeElements, fillElements: &fillElements)
    }
    
    func getOldValuePaths() -> (UIBezierPath, UIBezierPath) {
        var data :[ChartData] = control!.chartDataList
        dataSize = data.count
        if (dataSize == 0) { return (UIBezierPath(), UIBezierPath()) }
        
        maxValue  =  CGFloat(data.map { $0.oldValue }.max()!)
        hStepSize = width / CGFloat(dataSize)
        vStepSize = (height * 0.5) / maxValue
        var fillElements   : [CGPoint] = []
        var strokeElements : [CGPoint] = []
        fillElements.append(CGPoint(x: 0, y: height))
        strokeElements.append(CGPoint(x: 0, y: height - data[0].oldValue * vStepSize))
        
        for i in 0..<dataSize {
            fillElements.append(CGPoint(x: CGFloat(i + 1) * hStepSize, y: height - data[i].oldValue * vStepSize))
            strokeElements.append(CGPoint(x: CGFloat(i + 1) * hStepSize, y: height - data[i].oldValue * vStepSize))
        }
        
        fillElements.append(CGPoint(x: width, y: height))
        return smooth(strokeElements: &strokeElements, fillElements: &fillElements)
    }
    
    func smooth(strokeElements : inout [CGPoint], fillElements : inout [CGPoint]) -> (UIBezierPath, UIBezierPath) {
        if (fillElements.isEmpty) { return (UIBezierPath(), UIBezierPath())}
        var dataPoints : [CGPoint] = []
        for i in 0..<strokeElements.count {
            dataPoints.insert(CGPoint(x: strokeElements[i].x, y: strokeElements[i].y), at: i)
        }
        
        // next we need to know the zero Y value
        let zeroY = fillElements[0].y
        // now clear and rebuild elements
        //strokeElements.removeAll()
        //fillElements.removeAll()
        let result : ([CGPoint], [CGPoint]) = calcCurveControlPoints(dataPoints: dataPoints)
        var firstControlPoints  = result.0
        var secondControlPoints = result.1
        
        // clear both paths
        let strokePath : UIBezierPath = UIBezierPath()
        let fillPath   : UIBezierPath = UIBezierPath()
        
        // start both paths
        strokePath.move(to: CGPoint(x: dataPoints[0].x, y: dataPoints[0].y))
        fillPath.move(to: CGPoint(x: dataPoints[0].x, y: zeroY))
        fillPath.addLine(to: CGPoint(x: dataPoints[0].x, y: dataPoints[0].y))
        
        // add curves
        for i in 2..<dataPoints.count {
            let ci = i - 1
            let point         = CGPoint(x: dataPoints[i].x, y: dataPoints[i].y)
            let controlPoint1 = CGPoint(x: firstControlPoints[ci].x, y: firstControlPoints[ci].y)
            let controlPoint2 = CGPoint(x: secondControlPoints[ci].x, y: secondControlPoints[ci].y)
            strokePath.addCurve(to: point, controlPoint1: controlPoint1, controlPoint2: controlPoint2)
            fillPath.addCurve(to: point, controlPoint1: controlPoint1, controlPoint2: controlPoint2)
        }
        // end the paths
        fillPath.addLine(to: CGPoint(x: dataPoints[dataPoints.count - 1].x, y: zeroY))
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
        return x;
    }
    
    func animateChart() {
        let oldPaths : (UIBezierPath, UIBezierPath) = getOldValuePaths()
        let newPaths : (UIBezierPath, UIBezierPath) = getValuePaths()
        
        fillPath.removeAllPoints()
        fillPath.append(oldPaths.1)
        
        let toFillPath                   = newPaths.1
        let animation0                   = CABasicAnimation(keyPath: "path")
        animation0.fromValue             = fillPath.cgPath
        animation0.toValue               = toFillPath.cgPath
        animation0.duration              = control!.animationDuration
        animation0.timingFunction        = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        animation0.fillMode              = kCAFillModeForwards
        animation0.isRemovedOnCompletion = false
        
        strokePath.removeAllPoints()
        strokePath.append(oldPaths.0)
        
        let toStrokePath                 = newPaths.0
        let animation1                   = CABasicAnimation(keyPath: "path")
        animation1.fromValue             = strokePath.cgPath
        animation1.toValue               = toStrokePath.cgPath
        animation1.duration              = control!.animationDuration
        animation1.timingFunction        = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        animation1.fillMode              = kCAFillModeForwards
        animation1.isRemovedOnCompletion = false
        
        fillLayer.add(animation0, forKey: "animateChart")
        strokeLayer.add(animation1, forKey: "animateChart")
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
                     frame   : CGRect(x: size * 0.05, y: size * 0.05, width: width - size * 0.1, height: height * 0.08),
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
            
            // Value
            let formatString = "%.\(ctrl.decimals)f"
            
            let unitFont     = UIFont.init(name: "Lato-Regular", size: size * 0.12)
            let bigFont      = UIFont.init(name: "Lato-Regular", size: size * 0.24)
            
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
            
            // Chart
            hStepSize = width / CGFloat(dataSize)
            vStepSize = (height * 0.5) / maxValue
            
            let newPaths : (UIBezierPath, UIBezierPath) = getValuePaths()
            
            fillPath.removeAllPoints()
            fillPath.append(newPaths.1)
            fillLayer.frame         = CGRect(x: 0, y: 0, width: width, height: height)
            fillLayer.path          = fillPath.cgPath
            fillLayer.fillColor     = ctrl.barColor.withAlphaComponent(CGFloat(0.5)).cgColor
            
            /*
            let fillPathColor1       = ctrl.barColor.withAlphaComponent(CGFloat(0.7)).cgColor
            let fillPathColor2       = ctrl.barColor.withAlphaComponent(CGFloat(0.1)).cgColor
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
            strokeLayer.strokeColor = ctrl.barColor.cgColor
            
            let clippingPathFill   = UIBezierPath(roundedRect: bounds, cornerRadius: size * 0.025)
            let clippingLayerFill  = CAShapeLayer()
            clippingLayerFill.path = clippingPathFill.cgPath
            fillLayer.mask         = clippingLayerFill
            
            let clippingPathStroke   = UIBezierPath(roundedRect: bounds, cornerRadius: size * 0.025)
            let clippingLayerStroke  = CAShapeLayer()
            clippingLayerStroke.path = clippingPathStroke.cgPath
            strokeLayer.mask         = clippingLayerStroke
        }
        UIGraphicsPopContext()
    }
}
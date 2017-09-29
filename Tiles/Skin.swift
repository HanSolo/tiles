//
//  Skin.swift
//  Tiles
//
//  Created by Gerrit Grunwald on 28.09.17.
//  Copyright © 2017 Gerrit Grunwald. All rights reserved.
//

import UIKit

class GaugeSkin: CALayer {
    weak var control: Tile?
    var      size      : CGFloat = Tools.DEFAULT_SIZE
    var      center    : CGFloat = Tools.DEFAULT_SIZE * 0.5
    var      angleStep : CGFloat = .pi / 100.0
    
    let valueLabel     = UILabel()
    let minValueLabel  = UILabel()
    let maxValueLabel  = UILabel()
    let thresholdLabel = UILabel()    
    var pointer        = CALayer()
    var pointerView    = UIView()

    
    
    // ******************** Constructors ********************
    override init() {
        super.init()
    }
    override init(layer: Any) {
        super.init(layer: layer)
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    // ******************** Methods ********************
    func update(cmd: String) {
        if (cmd == Tools.INIT) {
            control!.addSubview(valueLabel)
            control!.addSubview(minValueLabel)
            control!.addSubview(maxValueLabel)
            control!.addSubview(thresholdLabel)
            
            pointer.contentsScale = UIScreen.main.scale
            pointer.anchorPoint = CGPoint(x: 0.5, y: 0.76)
            control!.addSubview(pointerView)
            
            pointerView.layer.addSublayer(pointer)
        } else if (cmd == Tools.REDRAW) {
            setNeedsDisplay()
        } else if (cmd == Tools.RECALC) {
            angleStep = .pi / control!.range
        }
    }
    func update<T>(prop: String, value: T) {
        if (prop == "value") {            
            pointer.setAffineTransform(control!.value == 0 ? .identity : CGAffineTransform(rotationAngle: (angleStep * control!.value)))
        }
    }
    
    override func layoutSublayers() {
        super.layoutSublayers()
        
        pointerView.frame = bounds
        pointer.frame = bounds
        pointer.contents = drawPointer(in: bounds)?.cgImage
    }
    
    
    

    // ******************** Redraw ********************
    override func draw(in ctx: CGContext) {
        super.draw(in: ctx)
        if let ctrl = control {
            size   = ctrl.size
            center = size * 0.5
            
            // Background
            let path = UIBezierPath(roundedRect: bounds, cornerRadius: size * 0.025)
            ctx.setFillColor(ctrl.bkgColor.cgColor)
            ctx.addPath(path.cgPath)
            ctx.fillPath()
            
            let font = UIFont.init(name: "Lato-Regular", size: size * 0.06)
            
            // Tile Title
            ctrl.titleLabel.text      = ctrl.title
            ctrl.titleLabel.textColor = ctrl.fgdColor
            ctrl.titleLabel.font      = font
            ctrl.titleLabel.center    = CGPoint(x: size * 0.05, y: size * 0.05)
            ctrl.titleLabel.frame     = CGRect(x: size * 0.05, y: size * 0.05, width: frame.width - size * 0.1, height: size * 0.06)
            ctrl.titleLabel.setNeedsDisplay()
            
            // Tile Text
            ctrl.textLabel.text      = ctrl.text
            ctrl.textLabel.textColor = ctrl.fgdColor
            ctrl.textLabel.font      = font
            ctrl.textLabel.center    = CGPoint(x: size * 0.05, y: size * 0.05)
            ctrl.textLabel.frame     = CGRect(x: size * 0.05, y: size * 0.89, width: frame.width - size * 0.1, height: size * 0.06)
            ctrl.textLabel.setNeedsDisplay()
            
            // Track
            let radius  = size * 0.3
            let track:UIBezierPath = UIBezierPath()
            track.addArc(withCenter: CGPoint(x: center, y: center + size * 0.26),
                         radius: radius,
                         startAngle: 0.0, endAngle: CGFloat(Double.pi),
                         clockwise: false)
            ctx.setLineWidth(size * 0.045)
            ctx.addPath(track.cgPath)
            ctx.setStrokeColor(Tools.FGD_COLOR.cgColor)
            ctx.strokePath()
            
            // Threshold Area
            let thresholdAngle = CGFloat(Double.pi) / ctrl.range * (ctrl.range - ctrl.threshold)
            let thresholdTrack:UIBezierPath = UIBezierPath()
            thresholdTrack.addArc(withCenter: CGPoint(x: center, y: center + size * 0.26),
                                  radius: radius,
                                  startAngle: 0.0, endAngle: -thresholdAngle,
                                  clockwise: false)
            ctx.setLineWidth(size * 0.045)
            ctx.addPath(thresholdTrack.cgPath)
            ctx.setStrokeColor(Tools.BLUE.cgColor)
            ctx.strokePath()
            
            // Value text
            valueLabel.frame = CGRect(x: size * 0.05, y: center - size * 0.35, width: size * 0.9, height:size * 0.288)
            valueLabel.textAlignment = .center
            valueLabel.text = String(format: "%.0f", ctrl.currentValue)
            valueLabel.numberOfLines = 1
            valueLabel.textColor = ctrl.fgdColor
            valueLabel.backgroundColor = UIColor.clear
            valueLabel.font = UIFont.init(name: "Lato-Regular", size: size * 0.24)
            valueLabel.setNeedsDisplay()
        
            // Min Value Text
            minValueLabel.textAlignment = .center
            minValueLabel.text = String(format: "%.0f", ctrl.minValue)
            minValueLabel.numberOfLines = 1
            minValueLabel.sizeToFit()
            minValueLabel.frame = CGRect(x: center - size * 0.375, y: center + size * 0.255, width: size * 0.15, height:size * 0.1)
            minValueLabel.textColor = ctrl.fgdColor
            minValueLabel.backgroundColor = UIColor.clear
            minValueLabel.font = UIFont.init(name: "Lato-Regular", size: size * 0.07)
            minValueLabel.setNeedsDisplay()
            
            // Max Value Text
            maxValueLabel.textAlignment = .center
            maxValueLabel.text = String(format: "%.0f", ctrl.maxValue)
            maxValueLabel.numberOfLines = 1
            maxValueLabel.sizeToFit()
            maxValueLabel.frame = CGRect(x: center + size * 0.22, y: center + size * 0.255, width: size * 0.15, height:size * 0.1)
            maxValueLabel.textColor = ctrl.fgdColor
            maxValueLabel.backgroundColor = UIColor.clear
            maxValueLabel.font = UIFont.init(name: "Lato-Regular", size: size * 0.07)
            maxValueLabel.setNeedsDisplay()
            
            // Threshold Text
            thresholdLabel.textAlignment = .center
            thresholdLabel.text = String(format: "%.0f", ctrl.threshold)
            thresholdLabel.numberOfLines = 1
            thresholdLabel.sizeToFit()
            thresholdLabel.frame = CGRect(x: (size - thresholdLabel.frame.width - size * 0.05) * 0.5, y: center + size * 0.35, width: (thresholdLabel.frame.width + size * 0.05), height: thresholdLabel.frame.height)
            thresholdLabel.textColor = ctrl.bkgColor
            thresholdLabel.backgroundColor = Tools.GRAY
            thresholdLabel.layer.masksToBounds = true
            thresholdLabel.layer.cornerRadius = size * 0.0125
            thresholdLabel.font = UIFont.init(name: "Lato-Regular", size: size * 0.08)
            thresholdLabel.setNeedsDisplay()
        }
    }
    
    func drawPointer(in rect: CGRect) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        guard let ctx = UIGraphicsGetCurrentContext() else { return nil }
        
        let size   : CGFloat = rect.size.width < rect.size.height ? rect.size.width : rect.size.height
        let center : CGFloat = size * 0.5
        
        // NeedleRect
        ctx.saveGState()
        let needleRect       = UIBezierPath(rect: CGRect(x: 0 , y: -size * 0.025, width: size * 0.035, height: size * 0.06))
        let needleRectBounds = needleRect.cgPath.boundingBox
        
        let translateRectTo  = CGPoint(x: (size - needleRectBounds.width) * 0.5, y: center - size * 0.0425)
        ctx.translateBy(x: translateRectTo.x, y: translateRectTo.y)
        
        let rotateRectAround = CGPoint(x: needleRectBounds.width * 0.5, y: size * 0.30625)
        ctx.translateBy(x: rotateRectAround.x, y: rotateRectAround.y)
        ctx.rotate(by: -.pi * 0.5)
        ctx.translateBy(x: -rotateRectAround.x, y: -rotateRectAround.y)
        
        ctx.setFillColor(Tools.BKG_COLOR.cgColor)
        ctx.addPath(needleRect.cgPath)
        ctx.fillPath()
        
        ctx.restoreGState()
        
        
        // Needle
        ctx.saveGState()
        let needleWidth  = CGFloat(size * 0.05)
        let needleHeight = CGFloat(size * 0.3325)
        let needle       = UIBezierPath()
        needle.move(to: CGPoint(x: 0.25 * needleWidth, y: 0.924812030075188 * needleHeight))
        needle.addCurve(to: CGPoint(x: 0.5 * needleWidth, y: 0.8872180451127819 * needleHeight),
                        controlPoint1: CGPoint(x: 0.25 * needleWidth, y: 0.9022556390977443 * needleHeight),
                        controlPoint2: CGPoint(x: 0.35 * needleWidth, y: 0.8872180451127819 * needleHeight))
        needle.addCurve(to: CGPoint(x: 0.75 * needleWidth, y: 0.924812030075188 * needleHeight),
                        controlPoint1: CGPoint(x: 0.65 * needleWidth, y: 0.8872180451127819 * needleHeight),
                        controlPoint2: CGPoint(x: 0.75 * needleWidth, y: 0.9022556390977443 * needleHeight))
        needle.addCurve(to: CGPoint(x: 0.5 * needleWidth, y: 0.9624060150375939 * needleHeight),
                        controlPoint1: CGPoint(x: 0.75 * needleWidth, y: 0.9473684210526315 * needleHeight),
                        controlPoint2: CGPoint(x: 0.65 * needleWidth, y: 0.9624060150375939 * needleHeight))
        needle.addCurve(to: CGPoint(x: 0.25 * needleWidth, y: 0.924812030075188 * needleHeight),
                        controlPoint1: CGPoint(x: 0.35 * needleWidth, y: 0.9624060150375939 * needleHeight),
                        controlPoint2: CGPoint(x: 0.25 * needleWidth, y: 0.9473684210526315 * needleHeight))
        needle.close()
        needle.move(to: CGPoint(x: 0.0, y: 0.924812030075188 * needleHeight))
        needle.addCurve(to: CGPoint(x: 0.5 * needleWidth, y: needleHeight),
                        controlPoint1: CGPoint(x: 0.0, y: 0.9699248120300752 * needleHeight),
                        controlPoint2: CGPoint(x: 0.2 * needleWidth, y: needleHeight))
        needle.addCurve(to: CGPoint(x: needleWidth, y: 0.924812030075188 * needleHeight),
                        controlPoint1: CGPoint(x: 0.8 * needleWidth, y: needleHeight),
                        controlPoint2: CGPoint(x: needleWidth, y: 0.9699248120300752 * needleHeight))
        needle.addCurve(to: CGPoint(x: 0.65 * needleWidth, y: 0.849624060150376 * needleHeight),
                        controlPoint1: CGPoint(x: needleWidth, y: 0.8947368421052632 * needleHeight),
                        controlPoint2: CGPoint(x: 0.85 * needleWidth, y: 0.8646616541353384 * needleHeight))
        needle.addCurve(to: CGPoint(x: 0.65 * needleWidth, y: 0.022556390977443608 * needleHeight),
                        controlPoint1: CGPoint(x: 0.65 * needleWidth, y: 0.849624060150376 * needleHeight),
                        controlPoint2: CGPoint(x: 0.65 * needleWidth, y: 0.022556390977443608 * needleHeight))
        needle.addCurve(to: CGPoint(x: 0.5 * needleWidth, y: 0.0),
                        controlPoint1: CGPoint(x: 0.65 * needleWidth, y: 0.007518796992481203 * needleHeight),
                        controlPoint2: CGPoint(x: 0.6 * needleWidth, y: 0.0))
        needle.addCurve(to: CGPoint(x: 0.35 * needleWidth, y: 0.022556390977443608 * needleHeight),
                        controlPoint1: CGPoint(x: 0.4 * needleWidth, y: 0.0),
                        controlPoint2: CGPoint(x: 0.35 * needleWidth, y: 0.007518796992481203 * needleHeight))
        needle.addCurve(to: CGPoint(x: 0.35 * needleWidth, y: 0.849624060150376 * needleHeight),
                        controlPoint1: CGPoint(x: 0.35 * needleWidth, y: 0.022556390977443608 * needleHeight),
                        controlPoint2: CGPoint(x: 0.35 * needleWidth, y: 0.849624060150376 * needleHeight))
        needle.addCurve(to: CGPoint(x: 0.0, y: 0.924812030075188 * needleHeight),
                        controlPoint1: CGPoint(x: 0.15 * needleWidth, y: 0.8646616541353384 * needleHeight),
                        controlPoint2: CGPoint(x: 0.0, y: 0.8947368421052632 * needleHeight))
        needle.close()
        
        // Translate ctx to needle position
        let translateNeedleTo  = CGPoint(x: (size - needleWidth) * 0.5, y: center - size * 0.0425)
        ctx.translateBy(x: translateNeedleTo.x, y: translateNeedleTo.y)
        
        // Rotate ctx according to zero
        let rotateNeedleAround = CGPoint(x: needleWidth * 0.5, y: needleHeight - needleWidth * 0.5)
        ctx.translateBy(x: rotateNeedleAround.x, y: rotateNeedleAround.y)
        ctx.rotate(by: -.pi * 0.5)
        ctx.translateBy(x: -rotateNeedleAround.x, y: -rotateNeedleAround.y)
        
        ctx.setFillColor(Tools.FGD_COLOR.cgColor)
        ctx.addPath(needle.cgPath)
        ctx.fillPath()
        
        ctx.restoreGState()
        let pointerImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        return pointerImage
    }
}

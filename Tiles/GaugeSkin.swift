//
//  GaugeSkin.swift
//  Tiles
//
//  Created by Gerrit Grunwald on 28.09.17.
//  Copyright © 2017 Gerrit Grunwald. All rights reserved.
//

import UIKit


class GaugeSkin: Skin {
    var angleStep : CGFloat = .pi / 100.0
    
    let valueLabel     = AnimLabel()
    let minValueLabel  = UILabel()
    let maxValueLabel  = UILabel()
    let thresholdLabel = UILabel()
    var pointer        = CALayer()
    var pointerView    = UIView()
    
    
    
    // ******************** Constructors **************
    override init() {
        super.init()
        valueLabel.method = .easeInOut
    }
    override init(layer: Any) {
        super.init(layer: layer)
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    // ******************** Methods *******************
    override func update(cmd: String) {
        if (cmd == Helper.INIT) {
            control!.textVisible = false
            control!.addSubview(valueLabel)
            control!.addSubview(minValueLabel)
            control!.addSubview(maxValueLabel)
            control!.addSubview(thresholdLabel)
            
            pointer.contentsScale = UIScreen.main.scale
            pointer.anchorPoint = CGPoint(x: 0.5, y: 0.765)
            control!.addSubview(pointerView)
            
            pointerView.layer.anchorPoint = CGPoint(x: 0.5, y: 0.765)
            pointerView.layer.addSublayer(pointer)
        } else if (cmd == Helper.REDRAW) {
            setNeedsDisplay()
        } else if (cmd == Helper.RECALC) {
            angleStep = .pi / control!.range
        }
    }
    override func update<T>(prop: String, value: T) {
        if (prop == "value") {
            valueLabel.countFrom(control!.oldValue, to: control!.value, withDuration: control!.animationDuration)
            
            thresholdLabel.backgroundColor = control!.value > control!.threshold ? control!.thresholdColor : Helper.GRAY
            thresholdLabel.setNeedsDisplay()
            
            UIView.animate(withDuration: control!.animationDuration, delay: 0.0, options: UIViewAnimationOptions.curveEaseInOut, animations: {
                self.pointerView.transform = CGAffineTransform(rotationAngle: (self.angleStep * self.control!.value))
            }, completion: nil)
        }
    }
    
    override func layoutSublayers() {
        super.layoutSublayers()
        
        pointerView.frame = bounds
        pointer.frame     = bounds
        pointer.contents  = drawPointer(in: bounds)?.cgImage
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
            let mediumFont = UIFont.init(name: "Lato-Regular", size: size * 0.07)
            let biggerFont = UIFont.init(name: "Lato-Regular", size: size * 0.08)
            let unitFont   = UIFont.init(name: "Lato-Regular", size: size * 0.1)
            let bigFont    = UIFont.init(name: "Lato-Regular", size: size * 0.24)
            
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
            
            // Track
            let radius = size * 0.3
            let track  = UIBezierPath()
            track.addArc(withCenter: CGPoint(x: centerX, y: centerY + size * 0.26),
                         radius    : radius,
                         startAngle: 0.0,
                         endAngle  : CGFloat(Double.pi),
                         clockwise : false)
            ctx.setLineWidth(size * 0.045)
            ctx.addPath(track.cgPath)
            ctx.setStrokeColor(Helper.FGD_COLOR.cgColor)
            ctx.strokePath()
            
            // Threshold Area
            let thresholdAngle = (ctrl.maxValue - ctrl.threshold) * angleStep
            let thresholdTrack = UIBezierPath()
            thresholdTrack.addArc(withCenter: CGPoint(x: centerX, y: centerY + size * 0.26),
                                  radius    : radius,
                                  startAngle: 0.0, endAngle: -thresholdAngle,
                                  clockwise : false)
            ctx.setLineWidth(size * 0.045)
            ctx.addPath(thresholdTrack.cgPath)
            ctx.setStrokeColor(Helper.BLUE.cgColor)
            ctx.strokePath()
            
            let formatString          = "%.\(ctrl.decimals)f"
            let tickLabelFormatString = "%.\(ctrl.tickLabelDecimals)f"
            
            // Value and Unit text
            valueLabel.frame           = CGRect(x: size * 0.05, y: centerY - size * 0.35, width: size * 0.9, height:size * 0.288)
            valueLabel.textAlignment   = .center            
            setAttributedFormatBlock (label       : valueLabel,
                                      valueFont   : bigFont!,
                                      formatString: formatString,
                                      valueColor  : ctrl.valueColor,
                                      unit        : ctrl.unit,
                                      unitFont    : unitFont!,
                                      unitColor   : ctrl.unitColor)
            valueLabel.numberOfLines   = 1
            valueLabel.backgroundColor = UIColor.clear
            valueLabel.setNeedsDisplay()
            valueLabel.countFrom(ctrl.oldValue, to: ctrl.value, withDuration: ctrl.animationDuration)
            
            // Min Value Text
            drawTextWithFormat(label   : minValueLabel,
                               font    : mediumFont!,
                               value   : ctrl.minValue,
                               fgdColor: ctrl.fgdColor,
                               bkgColor: ctrl.bkgColor,
                               radius  : 0,
                               format  : tickLabelFormatString,
                               align   : NSTextAlignment.center,
                               center  : CGPoint(x: centerX - size * 0.3, y: centerY + size * 0.325))
            
            // Max Value Text
            drawTextWithFormat(label   : maxValueLabel,
                               font    : mediumFont!,
                               value   : ctrl.maxValue,
                               fgdColor: ctrl.fgdColor,
                               bkgColor: ctrl.bkgColor,
                               radius  : 0,
                               format  : tickLabelFormatString,
                               align   : NSTextAlignment.center,
                               center  : CGPoint(x: centerX + size * 0.3, y: centerY + size * 0.325))
            
            // Threshold Text
            thresholdLabel.textAlignment       = .center
            thresholdLabel.text                = String(format: formatString, ctrl.threshold)
            thresholdLabel.numberOfLines       = 1
            thresholdLabel.sizeToFit()
            thresholdLabel.frame               = CGRect(x     : 0.5,
                                                        y     : 0.5,
                                                        width : (thresholdLabel.frame.width + size * 0.05),
                                                        height: size * 0.09)
            thresholdLabel.center              = CGPoint(x: size * 0.5, y: centerY + size * 0.35 + size * 0.045)
            thresholdLabel.textColor           = ctrl.bkgColor
            thresholdLabel.backgroundColor     = ctrl.value > ctrl.threshold ? ctrl.thresholdColor : Helper.GRAY
            thresholdLabel.layer.masksToBounds = true
            thresholdLabel.layer.cornerRadius  = size * 0.0125
            thresholdLabel.font                = biggerFont
            thresholdLabel.setNeedsDisplay()
        }
        UIGraphicsPopContext()
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
        
        ctx.setFillColor(Helper.BKG_COLOR.cgColor)
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
        
        ctx.setFillColor(Helper.FGD_COLOR.cgColor)
        ctx.addPath(needle.cgPath)
        ctx.fillPath()
        
        ctx.restoreGState()
        let pointerImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        return pointerImage
    }        
}

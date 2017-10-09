//
//  TimerControlSkin.swift
//  Tiles
//
//  Created by Gerrit Grunwald on 06.10.17.
//  Copyright © 2017 Gerrit Grunwald. All rights reserved.
//

import UIKit

class TimerControlSkin: Skin {
    private let CLOCK_SCALE_FACTOR = CGFloat(0.75)
    private let dateFormatter      = DateFormatter()
    private var clockSize          = CGFloat()
    private var sectionsPane       = CALayer()
    private var tickmarkLayer      = CALayer()
    private var tickmarkView       = UIView()
    private var minuteTickMarks    = UIBezierPath()
    private var hourTickMarks      = UIBezierPath()
    private var amPmText           = UILabel()
    private var dateText           = UILabel()
    private var hour               = UIBezierPath()
    private var minute             = UIBezierPath()
    private var second             = UIBezierPath()
    private var knob               = UIBezierPath()
    private var timer              = Timer()
    private var cal                = Calendar.current
    private var dateComponents     = Calendar.current.dateComponents(in: TimeZone.current, from: Date())
    
    
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
    @objc func tick() {
        dateComponents = cal.dateComponents(in: TimeZone.current, from: Date())
        setNeedsDisplay()
    }
    
    override func update(cmd: String) {
        guard let tile = control else { return }
        if (cmd == Helper.INIT) {
            dateFormatter.dateFormat = "EE d"
            
            tile.addSubview(amPmText)
            tile.addSubview(dateText)
            
            //tile.sendSubview(toBack: amPmText)
            //tile.sendSubview(toBack: dateText)
            
            tickmarkLayer.contentsScale   = UIScreen.main.scale
            tickmarkLayer.anchorPoint     = CGPoint(x: 0.5, y: 0.5)
            tickmarkLayer.shouldRasterize = true // caching to bitmap (only for layers that don't need frequent redraw)
            tile.addSubview(tickmarkView)
            
            tickmarkView.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            tickmarkView.layer.addSublayer(tickmarkLayer)
            
            timer = Timer.scheduledTimer(timeInterval: 1.0,
                                         target  : self,
                                         selector: #selector(tick),
                                         userInfo: nil,
                                         repeats : true)
        } else if (cmd == Helper.REDRAW) {
            setNeedsDisplay()
        } else if (cmd == Helper.SECTIONS) {
            setNeedsDisplay()
        }
    }
    override func update<T>(prop: String, value: T) {
        //guard let tile = control else { return }
        if (prop == "value") {
            
        }
    }
    
    override func layoutSublayers() {
        super.layoutSublayers()
        tickmarkView.frame     = bounds
        tickmarkLayer.frame    = bounds
        tickmarkLayer.contents = drawTickmarks(in: bounds)?.cgImage
    }
    
    
    // ******************** Event Handling ************
    /*
     override func onTileEvent(event: TileEvent) {
     switch(event.type) {
     case .VALUE(let value): break
     case .REDRAW          : break
     case .RECALC          : break
     }
     }
     */
    
    
    // ******************** Redraw ********************
    override func draw(in ctx: CGContext) {
        super.draw(in: ctx)
        guard let tile = control else { return }
        
        UIGraphicsPushContext(ctx)
        
        width     = self.frame.width
        height    = self.frame.height
        size      = width < height ? width : height
        clockSize = size * 0.75
        centerX   = width * 0.5
        centerY   = height * 0.5
        
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

        let time    = Date()
        let nowTime = cal.dateComponents([.hour, .minute, .second], from: time)
        let day     = cal.component(.weekday, from: Date())
        let nowHour = nowTime.hour
        let isAM    = nowHour! < 12
        
        // AM/PM Text
        drawText(label   : amPmText,
                 font    : smallFont!,
                 text    : isAM ? "AM" : "PM",
                 frame   : CGRect(x: size * 0.05, y: centerY - size * 0.2, width: width - size * 0.1, height: height * 0.08),
                 fgdColor: tile.fgdColor,
                 bkgColor: UIColor.clear,
                 radius  : 0,
                 align   : .center)
        
        // Date Text
        drawText(label   : dateText,
                 font    : smallFont!,
                 text    : dateFormatter.string(from: time),
                 frame   : CGRect(x: size * 0.05, y: centerY + size * 0.1, width: width - size * 0.1, height: height * 0.08),
                 fgdColor: tile.fgdColor,
                 bkgColor: UIColor.clear,
                 radius  : 0,
                 align   : .center)
        
        // Draw sections
        let offset            = Double(90.0)
        let angleStep         = Double(6.0)
        let highlightSections = tile.highlightSections
        
        for section in tile.timeSections {
            let start       = section.start
            let stop        = section.stop
            
            let startTime   = cal.dateComponents([.hour, .minute, .second], from: start)
            let startHour   = startTime.hour
            let startMinute = startTime.minute
            let startSecond = startTime.second
            let isStartAM   = startHour! < 12

            let stopTime    = cal.dateComponents([.hour, .minute, .second], from: stop)
            let stopHour    = stopTime.hour
            let stopMinute  = stopTime.minute
            let stopSecond  = stopTime.second
            let isStopAM    = stopHour! < 12
            
            section.active = section.contains(value: time)
            section.checkForTime(value: time)
            
            var draw = isAM ? (isStartAM || isStopAM) : (!isStartAM || !isStopAM)
            if (!section.days.contains(day) || !section.active) { draw = false }            
            if (draw) {
                let sectionStartAngle  = Double(startHour! % 12) * 5.0 + Double(startMinute!) / 12.0 + Double(startSecond!) / 300.0 * angleStep + 180.0
                var sectionAngleExtend = (Double((stopHour! - startHour!) % 12) * 5.0 + Double(stopMinute! - startMinute!) / 12.0 + Double(stopSecond! - startSecond!) / 300.0) * angleStep
                if (startHour! > stopHour!) { sectionAngleExtend = Double(360.0 - abs(sectionAngleExtend)) }
                let endAngle = offset + sectionStartAngle.truncatingRemainder(dividingBy: 360.0) + sectionAngleExtend.truncatingRemainder(dividingBy: 360.0)
                
                let arc = UIBezierPath(arcCenter : CGPoint(x: centerX, y: centerY),
                                       radius    : clockSize * 0.45,
                                       startAngle: CGFloat(Helper.toRadians(deg: (offset + sectionStartAngle.truncatingRemainder(dividingBy: 360.0)))),
                                       endAngle  : CGFloat(Helper.toRadians(deg: endAngle.truncatingRemainder(dividingBy: 360.0))),
                                       clockwise : true)
                
                ctx.addPath(arc.cgPath)
                ctx.setLineCap(CGLineCap.butt)
                ctx.setLineWidth(clockSize * 0.04)
                
                if (highlightSections) {
                    ctx.setStrokeColor(section.contains(value: time) ? section.highlightColor.cgColor : section.color.cgColor)
                } else {
                    ctx.setStrokeColor(section.color.cgColor)
                }
                ctx.strokePath()
            }
        }
        
        // Pointers
        hour = UIBezierPath(roundedRect: CGRect(x: (width - clockSize * 0.015) * 0.5, y: centerY - size * 0.165 / CLOCK_SCALE_FACTOR, width: clockSize * 0.015, height: clockSize * 0.29), cornerRadius: clockSize * 0.015)
        minute = UIBezierPath(roundedRect: CGRect(x: (width - clockSize * 0.015) * 0.5, y: centerY - size * 0.265 / CLOCK_SCALE_FACTOR, width: clockSize * 0.015, height: clockSize * 0.47), cornerRadius: clockSize * 0.015)
        second = UIBezierPath(roundedRect: CGRect(x: (width - clockSize * 0.005) * 0.5, y: centerY - size * 0.265 / CLOCK_SCALE_FACTOR, width: clockSize * 0.005, height: clockSize * 0.47), cornerRadius: clockSize * 0.015)
        
        knob = UIBezierPath(ovalIn: CGRect(x: centerX - clockSize * 0.0225, y: centerY - clockSize * 0.0225, width: clockSize * 0.045, height: clockSize * 0.045))
        
        var angle = Helper.toRadians(deg: CGFloat((60 * dateComponents.hour! + dateComponents.minute!) / 2))
        ctx.saveGState()
        ctx.translateBy(x: centerX, y: centerY)
        ctx.rotate(by: angle)
        ctx.translateBy(x: -centerX, y: -centerY)
        ctx.addPath(hour.cgPath)
        ctx.setFillColor(tile.hourColor.cgColor)
        ctx.fillPath()
        ctx.restoreGState()
        
        angle = Helper.toRadians(deg: CGFloat(dateComponents.minute! * 6 + dateComponents.second! / 10))
        ctx.saveGState()
        ctx.translateBy(x: centerX, y: centerY)
        ctx.rotate(by: angle)
        ctx.translateBy(x: -centerX, y: -centerY)
        ctx.addPath(minute.cgPath)
        ctx.setFillColor(tile.minuteColor.cgColor)
        ctx.fillPath()
        ctx.restoreGState()
        
        angle = Helper.toRadians(deg: CGFloat(dateComponents.second! * 6))
        ctx.saveGState()
        ctx.translateBy(x: centerX, y: centerY)
        ctx.rotate(by: angle)
        ctx.translateBy(x: -centerX, y: -centerY)
        ctx.addPath(second.cgPath)
        ctx.setFillColor(tile.secondColor.cgColor)
        ctx.fillPath()
        ctx.restoreGState()
        
        ctx.addPath(knob.cgPath)
        ctx.setFillColor(tile.knobColor.cgColor)
        ctx.fillPath()
        ctx.addPath(knob.cgPath)
        ctx.setLineWidth(CGFloat(1.0))
        ctx.setStrokeColor(tile.bkgColor.cgColor)
        ctx.strokePath()
        
        UIGraphicsPopContext()
    }
    
    func drawTickmarks(in rect: CGRect) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        guard let tile = control else { return UIImage() }
        guard let ctx  = UIGraphicsGetCurrentContext() else { return nil }
        
        let size   : CGFloat = rect.size.width < rect.size.height ? rect.size.width : rect.size.height
        let center = CGPoint(x: size * 0.5, y: size * 0.5)

        clockSize = size * 0.75

        hourTickMarks.removeAllPoints()
        minuteTickMarks.removeAllPoints()

        ctx.saveGState()
        var sinValue   : CGFloat
        var cosValue   : CGFloat
        var angle               = CGFloat(0.0)
        let startAngle          = CGFloat(Helper.toRadians(deg: 180.0))
        let angleStep           = CGFloat(Helper.toRadians(deg: (360.0 / 60.0)))
        let hourTickMarksVisible   = tile.hourTickMarksVisible
        let minuteTickMarksVisible = tile.minuteTickMarksVisible
        for counter in 0...59 {
            sinValue = sin(angle + startAngle)
            cosValue = cos(angle + startAngle)

            let innerPoint       = CGPoint(x: center.x + clockSize * 0.405 * sinValue, y: center.y + clockSize * 0.405 * cosValue)
            let innerMinutePoint = CGPoint(x: center.x + clockSize * 0.435 * sinValue, y: center.y + clockSize * 0.435 * cosValue)
            let outerPoint       = CGPoint(x: center.x + clockSize * 0.465 * sinValue, y: center.y + clockSize * 0.465 * cosValue)

            if (counter % 5 == 0) {
                if (hourTickMarksVisible) {
                    hourTickMarks.lineWidth = clockSize * 0.01
                    hourTickMarks.move(to: innerPoint)
                    hourTickMarks.addLine(to: outerPoint)
                } else {
                    minuteTickMarks.lineWidth = clockSize * 0.005
                    minuteTickMarks.move(to: innerMinutePoint)
                    minuteTickMarks.addLine(to: outerPoint)
                }
            } else if (counter % 1 == 0 && minuteTickMarksVisible) {
                minuteTickMarks.lineWidth = clockSize * 0.005
                minuteTickMarks.move(to: innerMinutePoint)
                minuteTickMarks.addLine(to: outerPoint)
            }
            angle -= angleStep
        }
        
        ctx.setStrokeColor(tile.fgdColor.cgColor)
        
        ctx.addPath(hourTickMarks.cgPath)
        ctx.strokePath()
        
        ctx.addPath(minuteTickMarks.cgPath)
        ctx.strokePath()
        
        ctx.restoreGState()

        let tickmarkImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        return tickmarkImage
    }
}

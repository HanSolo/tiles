//
//  Control.swift
//  Tiles
//
//  Created by Gerrit Grunwald on 28.09.17.
//  Copyright © 2017 Gerrit Grunwald. All rights reserved.
//

import UIKit


class Tile: UIControl {
    public enum SkinType {
        case TILE
        case GAUGE
        case MAP
        case CIRCULAR_PROGRESS
        case PERCENTAGE
        case SMOOTH_AREA
        case CLOCK
        case HIGH_LOW
        case NUMBER
        case TEXT
        case TIME_CONTROL
    }
    
    let events       = EventBus()
    
    var skin         :Skin = TileSkin()
    let titleLabel   = UILabel()
    let textLabel    = UILabel()
    
    var size                   : CGFloat = Helper.DEFAULT_SIZE
    var animationDuration      : Double  = 1.5
    var bkgColor               : UIColor = Helper.BKG_COLOR
    var fgdColor               : UIColor = Helper.FGD_COLOR
    var title                  : String = "Title"                       { didSet { skin.update(cmd: Helper.REDRAW) }}
    var text                   : String = "Text"                        { didSet { skin.update(cmd: Helper.REDRAW) }}
    var textVisible            : Bool   = true                          { didSet { skin.update(cmd: Helper.REDRAW) }}
    var unit                   : String = ""                            { didSet { skin.update(cmd: Helper.REDRAW) }}
    var descr                  : String = ""                            { didSet { skin.update(cmd: Helper.REDRAW) }}
    var minValue               : CGFloat = 0.0   {
        didSet {
            if (minValue > maxValue) { maxValue = minValue }
            skin.update(cmd: Helper.RECALC)
        }
    }
    var maxValue               : CGFloat = 100.0 {
        didSet {
            if (maxValue < minValue) { minValue = maxValue }
            skin.update(cmd: Helper.RECALC)
        }
    }
    var range                  : CGFloat { return maxValue - minValue }
    var threshold              : CGFloat = 100.0 { didSet { skin.update(cmd: Helper.REDRAW) }}
    var animated               : Bool = true
    var value                  : CGFloat = 0.0 {
        didSet {
            self.oldValue = oldValue
            if (oldValue < threshold && value > threshold) {
                skin.update(cmd: Helper.EXCEEDED)
            } else if (oldValue > threshold && value < threshold) {
                skin.update(cmd: Helper.UNDERRUN)
            } else {
                skin.update(cmd: Helper.UNCHANGED)
            }
            skin.update(prop: "value", value: value)
            //fireTileEvent(event: TileEvent(type: TileEventType.VALUE(value: value)))
        }
    }
    var oldValue               : CGFloat             = 0.0
    var referenceValue         : CGFloat             = 0.0
    var autoReferenceVAlue     : Bool                = true
    var decimals               : Int                 = 0                { didSet { skin.update(cmd: Helper.REDRAW) }}
    var tickLabelDecimals      : Int                 = 0                { didSet { skin.update(cmd: Helper.REDRAW) }}
    var location               : Location            = Location()       { didSet { skin.update(cmd: Helper.REDRAW) }}
    var barBackgroundColor     : UIColor             = Helper.BKG_COLOR { didSet { skin.update(cmd: Helper.REDRAW) }}
    var barColor               : UIColor             = Helper.BLUE      { didSet { skin.update(cmd: Helper.REDRAW) }}
    var graphicContainerVisible: Bool                = false            { didSet { skin.update(cmd: Helper.REDRAW) }}
    var valueColor             : UIColor             = Helper.FGD_COLOR { didSet { skin.update(cmd: Helper.REDRAW) }}
    var unitColor              : UIColor             = Helper.FGD_COLOR { didSet { skin.update(cmd: Helper.REDRAW) }}
    var thresholdColor         : UIColor             = Helper.BLUE      { didSet { skin.update(cmd: Helper.REDRAW) }}
    var chartDataList          : [ChartData]         = []               { didSet { skin.update(cmd: Helper.UPDATE) }}
    var sections               : [Section]           = [] {
        didSet {
            sections.sort { $0.start < $1.start }
            skin.update(cmd: Helper.SECTIONS)
        }
    }
    var timeSections           : [TimeSection]       = [] {
        didSet {
            timeSections.sort { $0.start < $1.start }
            skin.update(cmd: Helper.SECTIONS)
        }
    }
    var sectionsVisible        : Bool                = true             { didSet { skin.update(cmd: Helper.UPDATE) }}
    var titleAlignment         : NSTextAlignment     = .left            { didSet { titleLabel.textAlignment = titleAlignment }}
    var textAlignment          : NSTextAlignment     = .left            { didSet { textLabel.textAlignment = textAlignment   }}
    var hourTickMarksVisible   : Bool                = true             { didSet { skin.update(cmd: Helper.UPDATE) }}
    var minuteTickMarksVisible : Bool                = true             { didSet { skin.update(cmd: Helper.UPDATE) }}
    var highlightSections      : Bool                = false            { didSet { skin.update(cmd: Helper.UPDATE) }}
    var time                   : Date                = Date()           { didSet { skin.update(cmd: Helper.UPDATE) }}

    var hourColor              : UIColor             = Helper.FGD_COLOR { didSet { skin.update(cmd: Helper.UPDATE) }}
    var minuteColor            : UIColor             = Helper.FGD_COLOR { didSet { skin.update(cmd: Helper.UPDATE) }}
    var secondColor            : UIColor             = Helper.FGD_COLOR { didSet { skin.update(cmd: Helper.UPDATE) }}
    var knobColor              : UIColor             = Helper.FGD_COLOR { didSet { skin.update(cmd: Helper.UPDATE) }}
    
    var listeners              : [TileEventListener] = []
    
    
    
    // ******************** Constructor ***********************
    init(frame: CGRect, skinType: SkinType) {
        super.init(frame: frame)
        switch(skinType) {
            case SkinType.GAUGE            : skin = GaugeSkin(); break
            case SkinType.MAP              : skin = MapSkin(); break
            case SkinType.CIRCULAR_PROGRESS: skin = CircularProgressSkin(); break
            case SkinType.PERCENTAGE       : skin = PercentageSkin(); break
            case SkinType.SMOOTH_AREA      : skin = SmoothAreaTileSkin(); break
            case SkinType.CLOCK            : skin = ClockSkin(); break
            case SkinType.HIGH_LOW         : skin = HighLowSkin(); break
            case SkinType.NUMBER           : skin = NumberSkin(); break
            case SkinType.TEXT             : skin = TextSkin(); break
            case SkinType.TIME_CONTROL     : skin = TimerControlSkin(); break
        default                            : skin = TileSkin(); break
        }
        
        skin.control = self
        
        skin.contentsScale = UIScreen.main.scale
        layer.addSublayer(skin)
        
        titleLabel.textAlignment = titleAlignment
        addSubview(titleLabel)
        
        textLabel.textAlignment = textAlignment
        addSubview(textLabel)
        
        skin.update(cmd: "init")
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        skin = TileSkin()
        
        skin.control = self
        
        skin.contentsScale = UIScreen.main.scale
        layer.addSublayer(skin)
        
        titleLabel.textAlignment = NSTextAlignment.left
        addSubview(titleLabel)
        
        textLabel.textAlignment = NSTextAlignment.left
        addSubview(textLabel)
        
        skin.update(cmd: "init")
    }
    required init(coder: NSCoder) {
        super.init(coder: coder)!
    }
    
    
    // ******************** Methods ********************
    override var frame: CGRect {
        didSet {
            redraw()
        }
    }
    
    
    // ******************** Event Handling *************
    func addTileEventListener(listener: TileEventListener) {
        if (!listeners.isEmpty) {
            for i in 0...listeners.count { if (listeners[i] === listener) { return } }
        }
        listeners.append(listener)
    }
    func removeTileEventListener(listener: TileEventListener) {
        for i in 0...listeners.count {
            if listeners[i] === listener {
                listeners.remove(at: i)
                return
            }
        }
    }
    func fireTileEvent(event : TileEvent) {        
        listeners.forEach { listener in listener.onTileEvent(event: event) }
    }
    
    
    // ******************** Redraw *********************
    func redraw() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        size = frame.width < frame.height ? frame.width : frame.height
        
        skin.frame = bounds.insetBy(dx: 0.0, dy: 0.0)
        skin.setNeedsDisplay()
        
        CATransaction.commit()
    }
}

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
    }
    
    var skin         :Skin = TileSkin()
    let titleLabel   = UILabel()
    let textLabel    = UILabel()
    
    var size         : CGFloat = Helper.DEFAULT_SIZE
    
    var bkgColor     : UIColor = Helper.BKG_COLOR
    var fgdColor     : UIColor = Helper.FGD_COLOR
    
    var title        : String = "Title"
    var text         : String = "Text"
    var textVisible  : Bool   = true {
        didSet {
            skin.update(cmd: Helper.REDRAW)
        }
    }
    var unit         : String = "Unit"
    var minValue     : CGFloat = 0.0   {
        didSet {
            if (minValue > maxValue) { maxValue = minValue }
            skin.update(cmd: Helper.RECALC)
        }
        
    }
    var maxValue     : CGFloat = 100.0 {
        didSet {
            if (maxValue < minValue) { minValue = maxValue }
            skin.update(cmd: Helper.RECALC)
        }
    }
    var range        : CGFloat { return maxValue - minValue }
    var threshold    : CGFloat = 100.0 { didSet { skin.update(cmd: Helper.REDRAW) } }
    var animated     : Bool = true
    var value        : CGFloat = 0.0 {
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
            
            // Kick off animation
            //skin.setValue(value, forKey: "currentValue")
        }
    }
    var oldValue     : CGFloat  = 0.0
    var location     : Location = Location() {
        didSet { skin.update(cmd: Helper.REDRAW) }
    }
    
    
    
    // ******************** Constructor ***********************
    init(frame: CGRect, skinType: SkinType) {
        super.init(frame: frame)
        switch(skinType) {
            case SkinType.GAUGE: skin = GaugeSkin(); break
            case SkinType.MAP  : skin = MapSkin(); break
            default            : skin = TileSkin(); break
        }
        
        skin.control = self
        
        skin.contentsScale = UIScreen.main.scale
        layer.addSublayer(skin)
        
        titleLabel.textAlignment = NSTextAlignment.left
        addSubview(titleLabel)
        
        textLabel.textAlignment = NSTextAlignment.left
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
    
    
    // ******************** Methods *********************
    override var frame: CGRect {
        didSet {
            redraw()
        }
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

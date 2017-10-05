//
//  Skin.swift
//  Tiles
//
//  Created by Gerrit Grunwald on 29.09.17.
//  Copyright © 2017 Gerrit Grunwald. All rights reserved.
//

import UIKit


class Skin : CALayer, TileEventListener {
    public weak var control : Tile?
    var width               : CGFloat = Helper.DEFAULT_SIZE
    var height              : CGFloat = Helper.DEFAULT_SIZE
    var size                : CGFloat = Helper.DEFAULT_SIZE
    var centerX             : CGFloat = Helper.DEFAULT_SIZE * 0.5
    var centerY             : CGFloat = Helper.DEFAULT_SIZE * 0.5
    
    func update(cmd: String) {
        preconditionFailure("This method must be overridden")
    }
    
    func update<T>(prop: String, value: T) {
        preconditionFailure("This method must be overridden") 
    }
    
    func onTileEvent(event: TileEvent) {
        
    }
    
    func drawText(label : UILabel, font: UIFont, text: String, frame: CGRect, fgdColor: UIColor, bkgColor: UIColor, radius: CGFloat, align: NSTextAlignment) {
        label.textAlignment       = align
        label.text                = text
        label.numberOfLines       = 1
        label.sizeToFit()
        label.frame               = frame
        label.textColor           = fgdColor
        label.backgroundColor     = bkgColor
        label.font                = font
        //label.center              = CGPoint(x: size * 0.05, y: size * 0.05)
        label.layer.masksToBounds = true
        label.layer.cornerRadius  = radius
        label.setNeedsDisplay()
    }
    
    func drawTextWithFormat(label : UILabel, font: UIFont, value: CGFloat, fgdColor: UIColor, bkgColor: UIColor, radius: CGFloat, format: String, align: NSTextAlignment, center: CGPoint) {
        label.textAlignment       = align
        label.text                = String(format: format, value)
        label.numberOfLines       = 1
        label.sizeToFit()        
        label.textColor           = fgdColor
        label.backgroundColor     = bkgColor
        label.font                = font
        label.layer.masksToBounds = true
        label.layer.cornerRadius  = radius
        label.center              = center
        label.setNeedsDisplay()
    }
    
    func setAttributedFormatBlock (label: AnimLabel, valueFont: UIFont, formatString: String, valueColor: UIColor, unit: String, unitFont: UIFont, unitColor: UIColor) {
        label.attributedFormatBlock = {
            (value) in
            let formattedValue       = String(format: formatString, value)
            let formattedValueLength = formattedValue.characters.count
            let unitLength           = unit.characters.count
            let valueFontAttr        = [ NSAttributedStringKey.font: valueFont ]
            let valueUnitString      = NSMutableAttributedString(string: formattedValue, attributes: valueFontAttr)
            let unitFontAttr         = [ NSAttributedStringKey.font: unitFont ]
            let unitString           = NSAttributedString(string: unit, attributes: unitFontAttr)
            valueUnitString.append(unitString)
            valueUnitString.addAttribute(NSAttributedStringKey.foregroundColor, value: valueColor, range: NSRange(location: 0, length: formattedValueLength))
            if (!unit.characters.isEmpty) {
                valueUnitString.addAttribute(NSAttributedStringKey.foregroundColor, value: unitColor, range: NSRange(location: formattedValueLength, length: unitLength))
            }
            return valueUnitString
        }
    }    
}

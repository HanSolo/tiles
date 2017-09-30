//
//  Skin.swift
//  Tiles
//
//  Created by Gerrit Grunwald on 29.09.17.
//  Copyright © 2017 Gerrit Grunwald. All rights reserved.
//

import UIKit


class Skin :CALayer {
    public weak var control :Tile?
    
    func update(cmd: String) {
        preconditionFailure("This method must be overridden")
    }
    
    func update<T>(prop: String, value: T) {
        preconditionFailure("This method must be overridden") 
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
}

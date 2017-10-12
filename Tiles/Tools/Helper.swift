//
//  Tools.swift
//  Tiles
//
//  Created by Gerrit Grunwald on 25.09.17.
//  Copyright © 2017 Gerrit Grunwald. All rights reserved.
//
import UIKit


class Helper: NSObject {
    static let EPSILON       = CGFloat(1E-6)
    
    static let DEFAULT_SIZE  = CGFloat(200.0)
    
    static let BKG_COLOR     = UIColor(red: 0.165, green: 0.165, blue: 0.165, alpha: 1.0)
    static let FGD_COLOR     = UIColor(red: 0.8745098,  green: 0.8745098,  blue: 0.8745098,  alpha: 1.0)
    static let GRAY          = UIColor(red: 0.54509804, green: 0.56470588, blue: 0.57254902, alpha: 1.0)
    static let RED           = UIColor(red: 0.89803922, green: 0.31372549, blue: 0.29803922, alpha: 1.0)
    static let LIGHT_RED     = UIColor(red: 1.00000000, green: 0.32941176, blue: 0.21960784, alpha: 1.0)
    static let GREEN         = UIColor(red: 0.56078431, green: 0.77647059, blue: 0.36862745, alpha: 1.0)
    static let LIGHT_GREEN   = UIColor(red: 0.51764706, green: 0.89411765, blue: 0.19607843, alpha: 1.0)
    static let BLUE          = UIColor(red: 0.21568627, green: 0.70196078, blue: 0.98823529, alpha: 1.0)
    static let DARK_BLUE     = UIColor(red: 0.21568627, green: 0.36862745, blue: 0.98823529, alpha: 1.0)
    static let ORANGE        = UIColor(red: 0.92941176, green: 0.63529412, blue: 0.22352941, alpha: 1.0)
    static let YELLOW_ORANGE = UIColor(red: 0.89803922, green: 0.77647059, blue: 0.29803922, alpha: 1.0)
    static let YELLOW        = UIColor(red: 0.89803922, green: 0.89803922, blue: 0.29803922, alpha: 1.0)
    static let MAGENTA       = UIColor(red: 0.77647059, green: 0.29411765, blue: 0.90980392, alpha: 1.0)
    
    static let INIT          = String("init")
    static let REDRAW        = String("redraw")
    static let RECALC        = String("recalc")
    static let EXCEEDED      = String("exceeded")
    static let UNDERRUN      = String("underrun")
    static let UNCHANGED     = String("unchanged")
    static let UPDATE        = String("update")
    static let SECTIONS      = String("sections")
    static let TOUCH_BEGAN   = String("touchBegan")
    static let TOUCH_MOVED   = String("touchMoved")
    static let TOUCH_ENDED   = String("touchEnded")
    static let AVERAGING     = String("averaging")
    
    static func clamp(min: Double, max: Double, value: Double) -> Double {
        if (value < min) { return min }
        if (value > max) { return max }
        return value
    }
    static func clamp(min: CGFloat, max: CGFloat, value: CGFloat) -> CGFloat {
        if (value < min) { return min }
        if (value > max) { return max }
        return value
    }
    static func clamp(min: Int, max: Int, value: Int) -> Int {
        if (value < min) { return min }
        if (value > max) { return max }
        return value
    }
    
    static func toRadians(deg: Double) -> Double {
        return (deg * .pi / 180.0)
    }
    static func toRadians(deg: CGFloat) -> CGFloat {
        return (deg * .pi / 180.0)
    }
    
    static func toDegrees(rad: Double) -> Double {
        return (rad * 180.0 / .pi)
    }
    static func toDegrees(rad: CGFloat) -> CGFloat {
        return (rad * 180.0 / .pi)
    }
    
    static func equals(a: CGFloat, b: CGFloat) -> Bool {
        return a == b || abs(a - b) < EPSILON
    }
    static func biggerThan(a: CGFloat, b: CGFloat) -> Bool {
        return (a - b) > EPSILON
    }
    static func lessThan(a: CGFloat, b: CGFloat) -> Bool {
        return (b - a) > EPSILON
    }
}

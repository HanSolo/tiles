//
//  NiceScale.swift
//  Tiles
//
//  Created by Gerrit Grunwald on 09.10.17.
//  Copyright © 2017 Gerrit Grunwald. All rights reserved.
//

import UIKit

class NiceScale {
    private var min         : CGFloat
    private var max         : CGFloat
    private var maxTicks    : CGFloat = 10.0  { didSet{ calculate() } }
    private var tickSpacing : CGFloat = 1.0
    private var range       : CGFloat = 1.0
    private var niceMin     : CGFloat = 0.0
    private var niceMax     : CGFloat = 1.0
    
    
    convenience init() {
        self.init(min: 0.0, max: 100.0)
    }
    init(min: CGFloat, max: CGFloat) {
        self.min = min
        self.max = max
        calculate()
    }
    
    func calculate() {
        range       = niceNum(range: max - min, round: false)
        tickSpacing = niceNum(range: range / (maxTicks - 1), round: true)
        niceMin     = floor(min / tickSpacing) * tickSpacing
        niceMax     = ceil(max / tickSpacing) * tickSpacing
    }
    
    func niceNum(range: CGFloat, round: Bool) -> CGFloat {
        var exponent     : CGFloat // exponent of RANGE
        var fraction     : CGFloat // fractional part of RANGE
        var niceFraction : CGFloat // nice, rounded fraction
    
        exponent = floor(log10(range))
        fraction = range / pow(10, exponent)
    
        if (round) {
            if (fraction < 1.5) {
                niceFraction = 1
            } else if (fraction < 3) {
                niceFraction = 2
            } else if (fraction < 7) {
                niceFraction = 5
            } else {
                niceFraction = 10
            }
        } else {
            if (fraction <= 1) {
                niceFraction = 1
            } else if (fraction <= 2) {
                niceFraction = 2
            } else if (fraction <= 5) {
                niceFraction = 5
                
            } else {
                niceFraction = 10
            }
        }
        return niceFraction * pow(10, exponent)
    }
    
    func setMinMax(min: CGFloat, max: CGFloat) {
        self.min = min
        self.max = max
        calculate()
    }
    
    
    func getTickSpacing() -> CGFloat { return tickSpacing }
    
    func getNiceMin() -> CGFloat { return niceMin }
    
    func getNiceMax() -> CGFloat { return niceMax }
}

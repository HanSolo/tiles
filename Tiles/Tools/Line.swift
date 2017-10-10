//
//  Line.swift
//  Tiles
//
//  Created by Gerrit Grunwald on 10.10.17.
//  Copyright © 2017 Gerrit Grunwald. All rights reserved.
//

import UIKit

class Line {
    var from       : CGPoint
    var to         : CGPoint
    var dashArray  : [CGFloat] = []
    var strokeColor: UIColor   = UIColor.clear
    
    
    convenience init() {
        self.init(from: CGPoint(x: 0, y: 0), to: CGPoint(x: 0, y: 0))
    }
    convenience init(x1: CGFloat, y1: CGFloat, x2: CGFloat, y2: CGFloat) {
        self.init(from: CGPoint(x: x1, y: y1), to: CGPoint(x: x2, y: y2))
    }
    init(from: CGPoint, to: CGPoint) {
        self.from = from
        self.to   = to
    }
}

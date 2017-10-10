//
//  LinearGradient.swift
//  Tiles
//
//  Created by Gerrit Grunwald on 10.10.17.
//  Copyright © 2017 Gerrit Grunwald. All rights reserved.
//

import UIKit

class LinearGradient {
    var from  : CGPoint
    var to    : CGPoint
    var stops : [Stop]
    
    
    convenience init(from: CGPoint, to: CGPoint, stops: [Stop]) {
        self.init(from: from, to: to, stops: stops)
    }
    init(from: CGPoint, to: CGPoint, stops: Stop...) {
        self.from  = from
        self.to    = to
        self.stops = stops
    }
}

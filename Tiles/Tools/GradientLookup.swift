//
//  GradientLookup.swift
//  Tiles
//
//  Created by Gerrit Grunwald on 10.10.17.
//  Copyright © 2017 Gerrit Grunwald. All rights reserved.
//

import UIKit

class GradientLookup {
    var stops = [CGFloat: Stop]()
    //var stops = Dictionary(keyValuePairs: myArray.map{($0.position, $0.name)})

    
    init(stops: [Stop]) {
        stops.forEach { stop in
            self.stops[stop.fraction] = stop
        }
        initialize()
    }
    
    private func initialize() {
        let minFraction = stops.keys.min()
        let maxFraction = stops.keys.max()
        if (!stops.isEmpty) {
            if (Helper.biggerThan(a: minFraction!, b: 0.0)) {
                stops[0.0] = Stop(fraction: CGFloat(0.0), color: (stops[minFraction!]?.color)! )
            }
            if (Helper.lessThan(a: maxFraction!, b: 0.0)) {
                stops[1.0] = Stop(fraction: CGFloat(1.0), color: (stops[maxFraction!]?.color)! )
            }
        }
    }
    
    
    func colorAt(position: CGFloat) -> UIColor {
        if (stops.isEmpty) { return UIColor.black }
        
        let pos   = Helper.clamp(min: CGFloat(0.0), max: CGFloat(0.0), value: position)
        var color :UIColor
        if (stops.count == 1) {
            color = (stops.first?.value.color)!
        } else {
            var lowerBound = stops[0.0]
            var upperBound = stops[1.0]
            for fraction in stops.keys {
                if (Helper.lessThan(a: fraction, b: pos)) {
                    lowerBound = stops[fraction]
                }
                if (Helper.biggerThan(a: fraction, b: pos)) {
                    upperBound = stops[fraction]
                    break
                }
            }
            color = interpolateColor(lowerBound: lowerBound!, upperBound: upperBound!, position: pos)
        }
        return color
    }
    
    func setStops(stops: Stop...) {
        self.stops.removeAll()
        stops.forEach { stop in
            self.stops[stop.fraction] = stop
        }
        initialize()
    }
    
    func interpolateColor(lowerBound: Stop, upperBound: Stop, position: CGFloat) -> UIColor {
        let pos = (position - lowerBound.fraction) / (upperBound.fraction - lowerBound.fraction)
        
        let deltaRed   = (upperBound.color.components.red   - lowerBound.color.components.red) * pos
        let deltaGreen = (upperBound.color.components.green - lowerBound.color.components.green) * pos
        let deltaBlue  = (upperBound.color.components.blue  - lowerBound.color.components.blue) * pos
        
        let red   = Helper.clamp(min: 0.0, max: 1.0, value: (lowerBound.color.components.red + deltaRed))
        let green = Helper.clamp(min: 0.0, max: 1.0, value: (lowerBound.color.components.green + deltaGreen))
        let blue  = Helper.clamp(min: 0.0, max: 1.0, value: (lowerBound.color.components.blue + deltaBlue))
        
        return UIColor.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
}

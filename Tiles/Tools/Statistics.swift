//
//  Statistics.swift
//  Tiles
//
//  Created by Gerrit Grunwald on 09.10.17.
//  Copyright © 2017 Gerrit Grunwald. All rights reserved.
//

import UIKit

class Statistics {

    static func getMean(data: [CGFloat]) -> CGFloat {
        return data.reduce(0) { $0 + $1 } / CGFloat(data.count)
    }
    
    static func getVariance(data: [CGFloat]) -> CGFloat {
        let mean = getMean(data: data)
        var tmp  = CGFloat(0.0)
        for a in data { tmp += ((a - mean) * (a - mean)) }
        return tmp / CGFloat(data.count)
    }
    
    static func getStdDev(data: [CGFloat]) -> CGFloat { return sqrt(getVariance(data: data)) }
    
    static func getMedian(data: [CGFloat]) -> CGFloat {
        let size       = data.count
        let sortedData = data.sorted()
        return size % 2 == 0 ? sortedData[(size / 2) - 1] + sortedData[(size / 2)] / 2.0 : sortedData[size / 2]
    }
    
    static func getMin(data: [CGFloat]) -> CGFloat? { return data.min() }
    
    static func getMax(data: [CGFloat]) -> CGFloat? { return data.max() }
}

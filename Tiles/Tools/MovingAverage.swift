//
//  MovingAverage.swift
//  Tiles
//
//  Created by Gerrit Grunwald on 09.10.17.
//  Copyright © 2017 Gerrit Grunwald. All rights reserved.
//

import UIKit

class MovingAverage {
    static  let MAX_PERIOD     = 2073600 // 24h in seconds
    static  let DEFAULT_PERIOD = 10
    private var window         = Queue<TimeData>()
    private var computedPeriod : Int = 0
    private var period         : Int {
        get { return self.computedPeriod }
        set(newPeriod) {
            self.computedPeriod = Helper.clamp(min: 0, max: MovingAverage.MAX_PERIOD, value: newPeriod)
            reset()
        }
    }
    
    private var sum            = CGFloat(0.0)
    
    
    convenience init() {
        self.init(period: MovingAverage.DEFAULT_PERIOD)
    }
    init(period: Int) {
        self.period = Helper.clamp(min: 0, max: MovingAverage.MAX_PERIOD, value: period)        
    }
    
    
    func addData(data: TimeData) {        
        sum += data.value
        window.add(data)
        if (window.count > period) {
            sum -= (window.remove()?.value)!
        }
    }
    func addValue(value: CGFloat) {
        addData(data: TimeData(value: value))
    }
    func addListOfData(listOfData: [TimeData]) {
        listOfData.forEach { data in
            addData(data: data)
        }
    }
    
    func getFirstEntry() -> TimeData? { return window.first }
    func getLastEntry() -> TimeData? { return window.last }
    
    func getTimeSpan() -> TimeInterval {
        let firstEntry = getFirstEntry()
        let lastEntry  = getLastEntry()
        if (firstEntry == nil || lastEntry == nil) { return 0.0 }
        let secondsFirst = firstEntry?.timestamp.timeIntervalSince1970
        let secondsLast  = lastEntry?.timestamp.timeIntervalSince1970
        return TimeInterval(secondsLast! - secondsFirst!)
    }
    
    func getAverage() -> CGFloat {
        if (window.isEmpty) { return 0 }
        return (sum / CGFloat(window.count))
    }
    
    func getTimeBasedAverageOf(duration: Double) -> CGFloat {
        if (duration < 0) { return 0 }
        let now    = Date().timeIntervalSince1970
        var result = CGFloat(0.0)
        var count  = CGFloat(0.0)
        
        for i in 0..<window.count {
            let v = window[i]
            if (v.timestamp.timeIntervalSince1970 > (now - duration)) {
                result += v.value
                count  += 1
            }
        }
        return count > 0 ? CGFloat((result / count)) : CGFloat(0.0)
    }
    
    func isFilling() -> Bool { return window.count < period }
    
    func reset() { window.clear() }
}

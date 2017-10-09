//
//  ChartData.swift
//  Tiles
//
//  Created by Gerrit Grunwald on 02.10.17.
//  Copyright © 2017 Gerrit Grunwald. All rights reserved.
//

import UIKit

class ChartData {
    var         name                    : String  { didSet { fireChartDataEvent(event: ChartDataEvent(data: self)) } }
    var         color                   : UIColor { didSet { fireChartDataEvent(event: ChartDataEvent(data: self)) } }
    var         timestamp               : Date    { didSet { fireChartDataEvent(event: ChartDataEvent(data: self)) } }
    var         value                   : CGFloat { didSet { self.oldValue = oldValue; fireChartDataEvent(event: ChartDataEvent(data: self)) } }
    var         oldValue                : CGFloat
    private var chartDataEventListeners : [ChartDataEventListener] = []
    
    
    // ******************** Constructor ***********************
    convenience init() {
        self.init(name: "", color: Helper.BLUE, timestamp: Date(), value: 0.0)
    }
    convenience init(value: CGFloat) {
        self.init(name: "", color: Helper.BLUE, timestamp: Date(), value: value)
    }
    convenience init(value: CGFloat, timestamp: Date) {
        self.init(name: "", color: Helper.BLUE, timestamp: timestamp, value: value)
    }
    convenience init(name: String, value: CGFloat) {
        self.init(name: name, color: Helper.BLUE, timestamp: Date(), value: value)
    }
    convenience init(name: String, timestamp: Date, value: CGFloat) {
        self.init(name: name, color: Helper.BLUE, timestamp: timestamp, value: value)
    }
    convenience init(name: String, color: UIColor, value: CGFloat) {
        self.init(name: name, color: color, timestamp: Date(), value: value)
    }
    init(name: String, color: UIColor, timestamp: Date, value: CGFloat) {
        self.name      = name
        self.color     = color
        self.timestamp = timestamp
        self.value     = value
        self.oldValue  = value
    }
    
    
    // ******************** Event Handling *************
    func addChartDataEventListener(listener: ChartDataEventListener) {
        if (!chartDataEventListeners.isEmpty) {
            for i in 0..<chartDataEventListeners.count { if (chartDataEventListeners[i] === listener) { return } }
        }
        chartDataEventListeners.append(listener)
    }
    func removeChartDataEventListener(listener: ChartDataEventListener) {
        for i in 0...chartDataEventListeners.count {
            if chartDataEventListeners[i] === listener {
                chartDataEventListeners.remove(at: i)
                return
            }
        }
    }
    func fireChartDataEvent(event : ChartDataEvent) {
        chartDataEventListeners.forEach { listener in listener.onChartDataEvent(event: event) }
    }
}

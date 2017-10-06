//
//  ViewController.swift
//  Tiles
//
//  Created by Gerrit Grunwald on 25.09.17.
//  Copyright © 2017 Gerrit Grunwald. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    let circularProgressTile = Tile(frame: CGRect.zero, skinType: Tile.SkinType.CIRCULAR_PROGRESS)
    let gaugeTile            = Tile(frame: CGRect.zero, skinType: Tile.SkinType.GAUGE)
    let percentageTile       = Tile(frame: CGRect.zero, skinType: Tile.SkinType.PERCENTAGE)
    let smoothAreaTile       = Tile(frame: CGRect.zero, skinType: Tile.SkinType.SMOOTH_AREA)
    let clockTile            = Tile(frame: CGRect.zero, skinType: Tile.SkinType.CLOCK)
    //let highLowTile          = Tile(frame: CGRect.zero, skinType: Tile.SkinType.HIGH_LOW)
    let timeControlTile      = Tile(frame: CGRect.zero, skinType: Tile.SkinType.TIME_CONTROL)
    //let mapTile              = Tile(frame: CGRect.zero, skinType: Tile.SkinType.MAP)
    
    let chartData0           = ChartData(name: "0", timestamp: Date(), value: CGFloat(drand48() * 10.0))
    let chartData1           = ChartData(name: "1", timestamp: Date(), value: CGFloat(drand48() * 10.0))
    let chartData2           = ChartData(name: "2", timestamp: Date(), value: CGFloat(drand48() * 10.0))
    let chartData3           = ChartData(name: "3", timestamp: Date(), value: CGFloat(drand48() * 10.0))
    let chartData4           = ChartData(name: "4", timestamp: Date(), value: CGFloat(drand48() * 10.0))
    
    var timer                = Timer()
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(red: 0.0627451, green: 0.07058824, blue: 0.07843137, alpha: 1.0)
        
        view.addSubview(circularProgressTile)
        view.addSubview(gaugeTile)
        view.addSubview(percentageTile)
        view.addSubview(smoothAreaTile)
        view.addSubview(clockTile)
        //view.addSubview(highLowTile)
        view.addSubview(timeControlTile)
        //view.addSubview(mapTile)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        circularProgressTile.title    = "CircularProgressSkin"
        circularProgressTile.minValue = 0
        circularProgressTile.maxValue = 200
        circularProgressTile.unit     = "V"
        circularProgressTile.decimals = 1
        
        let section0 = Section(start: 20, stop: 50, color: Helper.RED)
        
        gaugeTile.minValue  = 0
        gaugeTile.maxValue  = 100
        gaugeTile.threshold = 75
        gaugeTile.title     = "GaugeSkin"
        gaugeTile.unit      = "V"
        gaugeTile.sections  = [section0]
        
        percentageTile.title    = "PercentageSkin"
        percentageTile.descr    = "Test"
        percentageTile.unit     = "V"
        percentageTile.maxValue = 60
        percentageTile.decimals = 1
        percentageTile.titleAlignment = .right
        
        smoothAreaTile.title = "SmoothAreaSkin"
        smoothAreaTile.unit  = "V"        
        smoothAreaTile.chartDataList.append(contentsOf: [ chartData0, chartData1, chartData2, chartData3, chartData4 ])
        
        clockTile.title = "ClockSkin"

        /*
        highLowTile.title             = "HighLowSkin"
        highLowTile.text              = "Whatever text"
        highLowTile.descr             = "Test"
        highLowTile.unit              = "%"
        highLowTile.referenceValue    = 6.7
        highLowTile.decimals          = 1
        highLowTile.tickLabelDecimals = 1
        */

        timeControlTile.title = "TimeControl"
        let startDate    = Date(day: 6, month: 10, year: 2017, hour: 22, minute: 0, second: 0)
        let endDate      = Date(day: 6, month: 10, year: 2017, hour: 23, minute: 0, second: 0)
        let timeSection0 = TimeSection(start: startDate!, stop: endDate!, color: Helper.RED, active: true)
        timeControlTile.timeSections.append(timeSection0)
        
        //mapTile.title    = "MapSkin"
        //mapTile.location = Location(latitude: 51.9065938, longitude: 7.6352688)
        
        runTimer()
    }
    
    override func viewDidLayoutSubviews() {
        let screenSize  :CGRect       = UIScreen.main.bounds
        let screenWidth :CGFloat      = screenSize.width
        //let screenHeight:CGFloat      = screenSize.height
        let margin      : CGFloat     = 5.0
        let width       : CGFloat     = (screenWidth - 3 * margin) / 2.0
        let height      : CGFloat     = width
        let safeArea    :UIEdgeInsets = view.safeAreaInsets
        
        circularProgressTile.frame = CGRect(x: margin, y: margin + safeArea.top, width: width, height: height)
        gaugeTile.frame            = CGRect(x: margin, y: margin + safeArea.top + height + margin, width: width, height: height)
        percentageTile.frame       = CGRect(x: margin, y: margin + safeArea.top + 2 * height + 2 * margin, width: width, height: height)
        smoothAreaTile.frame       = CGRect(x: margin + width + margin, y: margin + safeArea.top, width: width, height: height)
        clockTile.frame            = CGRect(x: margin + width + margin, y: margin + safeArea.top + height + margin, width: width, height: height)
        //highLowTile.frame          = CGRect(x: margin + width + margin, y: margin + safeArea.top + 2 * height + 2 * margin, width: width, height: height)
        timeControlTile.frame          = CGRect(x: margin + width + margin, y: margin + safeArea.top + 2 * height + 2 * margin, width: width, height: height)
        //mapTile.frame              = CGRect(x: margin, y: margin + safeArea.top + 2 * height + 2 * margin, width: width, height: height)
    }
    
    func runTimer() {
        timer = Timer.scheduledTimer(timeInterval: 4, target: self,   selector: (#selector(ViewController.updateTimer)), userInfo: nil, repeats: true)
    }
    
    @objc func updateTimer() {
        gaugeTile.value            = CGFloat(drand48() * 100.0)
        circularProgressTile.value = CGFloat(drand48() * 200.0)
        percentageTile.value       = CGFloat(drand48() * 200.0)
        
        chartData0.value           = chartData1.value
        chartData1.value           = chartData2.value
        chartData2.value           = chartData3.value
        chartData3.value           = chartData4.value
        chartData4.value           = CGFloat(drand48() * 10.0)
        
        //highLowTile.value          = CGFloat(drand48() * 10.0)
    }
}


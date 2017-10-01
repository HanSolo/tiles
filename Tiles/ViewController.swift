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
    //let mapTile              = Tile(frame: CGRect.zero, skinType: Tile.SkinType.MAP)
    
    var timer     = Timer()
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(red: 0.0627451, green: 0.07058824, blue: 0.07843137, alpha: 1.0)
        
        view.addSubview(circularProgressTile)
        view.addSubview(gaugeTile)
        //view.addSubview(mapTile)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        circularProgressTile.title    = "CircularProgressSkin"
        circularProgressTile.minValue = 0
        circularProgressTile.maxValue = 200
        circularProgressTile.unit     = "V"
        circularProgressTile.decimals = 1
        
        gaugeTile.minValue  = 0
        gaugeTile.maxValue  = 100
        gaugeTile.threshold = 75
        gaugeTile.title     = "GaugeSkin"
        gaugeTile.unit      = "V"
        
        //mapTile.title    = "MapSkin"
        //mapTile.location = Location(latitude: 51.9065938, longitude: 7.6352688)
        
        runTimer()
    }
    
    override func viewDidLayoutSubviews() {
        let margin: CGFloat = 5.0
        let width : CGFloat = 200
        let height: CGFloat = 200
        let safeArea        = view.safeAreaInsets
        
        circularProgressTile.frame = CGRect(x: margin, y: margin + safeArea.top, width: width, height: height)
        gaugeTile.frame            = CGRect(x: margin, y: margin + safeArea.top + height + margin, width: width, height: height)
        //mapTile.frame              = CGRect(x: margin, y: margin + safeArea.top + 2 * height + 2 * margin, width: width, height: height)
    }
    
    func runTimer() {
        timer = Timer.scheduledTimer(timeInterval: 4, target: self,   selector: (#selector(ViewController.updateTimer)), userInfo: nil, repeats: true)
    }
    
    @objc func updateTimer() {
        gaugeTile.value            = CGFloat(drand48() * 100.0)
        circularProgressTile.value = CGFloat(drand48() * 200.0)
    }
}


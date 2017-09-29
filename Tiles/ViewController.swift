//
//  ViewController.swift
//  Tiles
//
//  Created by Gerrit Grunwald on 25.09.17.
//  Copyright © 2017 Gerrit Grunwald. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    let tile      = Tile(frame: CGRect.zero)
    let gaugeTile = Tile(frame: CGRect.zero, skinType: Tile.SkinType.GAUGE)
    
    var timer     = Timer()
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(tile)
        view.addSubview(gaugeTile)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tile.title = "TileSkin"
        tile.text  = "Text"
        
        gaugeTile.minValue  = 0
        gaugeTile.maxValue  = 100
        gaugeTile.threshold = 75
        gaugeTile.title     = "GaugeSkin"
        
        runTimer()
    }
    
    override func viewDidLayoutSubviews() {
        let margin: CGFloat = 5.0
        let width : CGFloat = 200
        let height: CGFloat = 200
        let safeArea        = view.safeAreaInsets
        
        tile.frame      = CGRect(x: margin, y: margin + safeArea.top, width: width, height: height)
        gaugeTile.frame = CGRect(x: margin, y: margin + safeArea.top + height + margin, width: width, height: height)
    }
    
    func runTimer() {
        timer = Timer.scheduledTimer(timeInterval: 4, target: self,   selector: (#selector(ViewController.updateTimer)), userInfo: nil, repeats: true)
    }
    
    @objc func updateTimer() {
        gaugeTile.value = CGFloat(drand48() * 100.0)
    }
}


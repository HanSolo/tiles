//
//  ViewController.swift
//  Tiles
//
//  Created by Gerrit Grunwald on 25.09.17.
//  Copyright © 2017 Gerrit Grunwald. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    let ctrl = Tile(frame: CGRect.zero)
    var timer = Timer()
   
    override func viewDidLoad() {
        super.viewDidLoad()
                
        view.addSubview(ctrl)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        ctrl.threshold = 75
        ctrl.title     = "Test"
        
        runTimer()
    }
    
    override func viewDidLayoutSubviews() {
        let margin: CGFloat = 5.0
        let width : CGFloat = 300
        let height: CGFloat = 300
        let safeArea        = view.safeAreaInsets        
        ctrl.frame = CGRect(x: margin, y: margin + safeArea.top, width: width, height: height)
    }
    
    func runTimer() {
        timer = Timer.scheduledTimer(timeInterval: 4, target: self,   selector: (#selector(ViewController.updateTimer)), userInfo: nil, repeats: true)
    }
    
    @objc func updateTimer() {
        ctrl.value = CGFloat(drand48() * 100.0)
    }
}


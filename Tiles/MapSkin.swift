//
//  MapSkin.swift
//  Tiles
//
//  Created by Gerrit Grunwald on 29.09.17.
//  Copyright © 2017 Gerrit Grunwald. All rights reserved.
//

import UIKit
import MapKit


class MapSkin: Skin, MKMapViewDelegate {
    var size   : CGFloat   = Helper.DEFAULT_SIZE
    var center : CGFloat   = Helper.DEFAULT_SIZE * 0.5
    var map    : MKMapView = MKMapView()
    
    
    // ******************** Constructors ********************
    override init() {
        super.init()
    }
    override init(layer: Any) {
        super.init(layer: layer)
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    // ******************** Methods ********************
    override func update(cmd: String) {
        if (cmd == Helper.INIT) {
            size                = control!.size
            center              = size * 0.5
            
            map.frame           = CGRect(x: size * 0.05, y: size * 0.15, width: size * 0.9, height: size - size * 0.27)
            map.mapType         = MKMapType.standard
            map.isZoomEnabled   = true
            map.isScrollEnabled = true
            map.backgroundColor = UIColor.red
            map.delegate        = self
            
            control!.addSubview(map)
        } else if (cmd == Helper.REDRAW) {
            setNeedsDisplay()
        }
    }
    override func update<T>(prop: String, value: T) {
        if (prop == "value") {
            
        }
    }
    
    override func layoutSublayers() {
        super.layoutSublayers()
        
    }
    
    
    // ******************** Redraw ********************
    override func draw(in ctx: CGContext) {
        super.draw(in: ctx)
        UIGraphicsPushContext(ctx)
        if let ctrl = control {
            size   = ctrl.size
            center = size * 0.5
            
            // Background
            let path = UIBezierPath(roundedRect: bounds, cornerRadius: size * 0.025)
            ctx.setFillColor(ctrl.bkgColor.cgColor)
            ctx.addPath(path.cgPath)
            ctx.fillPath()
            
            let smallFont  = UIFont.init(name: "Lato-Regular", size: size * 0.06)
            
            // Tile Title
            drawText(label: ctrl.titleLabel, font: smallFont!, text: ctrl.title, frame: CGRect(x: size * 0.05, y: size * 0.05, width: frame.width - size * 0.1, height: size * 0.08), fgdColor: ctrl.fgdColor, bkgColor: ctrl.bkgColor, radius: 0, align: .left)
            
            // Tile Text
            if (ctrl.textVisible) {
                drawText(label: ctrl.textLabel, font: smallFont!, text: ctrl.text, frame: CGRect(x: size * 0.05, y: size * 0.89, width: frame.width - size * 0.1, height: size * 0.08), fgdColor: ctrl.fgdColor, bkgColor: ctrl.bkgColor, radius: 0, align: .left)
            } else {
                ctrl.textLabel.textColor = UIColor.clear
            }
            
            // Map
            map.frame    = CGRect(x: size * 0.05, y: size * 0.15, width: size * 0.9, height: size - size * (ctrl.textVisible ? 0.27 : 0.205))
            let location = CLLocationCoordinate2D(latitude: ctrl.location.latitude, longitude: ctrl.location.longitude)
            let coordinateRegion = MKCoordinateRegionMakeWithDistance(location, 1000, 1000)            
            map.setRegion(coordinateRegion, animated: true)
            map.setCenter(location, animated: true)
        }
        UIGraphicsPopContext()
    }
    
    func drawText(label : UILabel, font: UIFont, text: String, frame: CGRect, fgdColor: UIColor, bkgColor: UIColor, radius: CGFloat, align: NSTextAlignment) {
        label.textAlignment       = align
        label.text                = text
        label.numberOfLines       = 1
        label.sizeToFit()
        label.frame               = frame
        label.textColor           = fgdColor
        label.backgroundColor     = bkgColor
        label.font                = font
        //label.center              = CGPoint(x: size * 0.05, y: size * 0.05)
        label.layer.masksToBounds = true
        label.layer.cornerRadius  = radius
        label.setNeedsDisplay()
    }
}

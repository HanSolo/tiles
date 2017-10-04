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
    var map    : MKMapView = MKMapView()
    let marker             = MKPointAnnotation()
    
    
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
            width   = self.frame.width
            height  = self.frame.height
            size    = width < height ? width : height
            centerX = width * 0.5
            centerY = height * 0.5
            
            map.frame           = CGRect(x: size * 0.05, y: size * 0.15, width: width * 0.9, height: height - size * 0.27)
            map.mapType         = MKMapType.standard
            map.isZoomEnabled   = true
            map.isScrollEnabled = true
            map.backgroundColor = UIColor.red
            map.delegate        = self
            map.addAnnotation(marker)
            
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
            width   = self.frame.width
            height  = self.frame.height
            size    = width < height ? width : height
            centerX = width * 0.5
            centerY = height * 0.5
            
            // Background
            let path = UIBezierPath(roundedRect: bounds, cornerRadius: size * 0.025)
            ctx.setFillColor(ctrl.bkgColor.cgColor)
            ctx.addPath(path.cgPath)
            ctx.fillPath()
            
            let smallFont  = UIFont.init(name: "Lato-Regular", size: size * 0.06)
            
            // Tile Title
            drawText(label   : ctrl.titleLabel,
                     font    : smallFont!,
                     text    : ctrl.title,
                     frame   : CGRect(x: size * 0.05, y: size * 0.05, width: width - size * 0.1, height: size * 0.08),
                     fgdColor: ctrl.fgdColor,
                     bkgColor: ctrl.bkgColor,
                     radius  : 0,
                     align   : .left)
            
            // Tile Text
            if (ctrl.textVisible) {
                drawText(label   : ctrl.textLabel,
                         font    : smallFont!,
                         text    : ctrl.text,
                         frame   : CGRect(x: size * 0.05, y: size * 0.89, width: width - size * 0.1, height: size * 0.08),
                         fgdColor: ctrl.fgdColor,
                         bkgColor: ctrl.bkgColor,
                         radius  : 0,
                         align   : .left)
            } else {
                ctrl.textLabel.textColor = UIColor.clear
            }
            
            // Map
            let location         = CLLocationCoordinate2D(latitude: ctrl.location.latitude, longitude: ctrl.location.longitude)
            let coordinateRegion = MKCoordinateRegionMakeWithDistance(location, 100, 100)
            let marker           = MKPointAnnotation()
            marker.coordinate    = CLLocationCoordinate2D(latitude: ctrl.location.latitude, longitude: ctrl.location.longitude)
            marker.title         = ctrl.location.name
            map.frame            = CGRect(x: size * 0.05, y: size * 0.15, width: width * 0.9, height: height - size * (ctrl.textVisible ? 0.27 : 0.205))
            map.setRegion(coordinateRegion, animated: true)
            map.setCenter(location, animated: true)
        }
        UIGraphicsPopContext()
    }
}

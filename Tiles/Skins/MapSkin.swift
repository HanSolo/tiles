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
    private var map    : MKMapView = MKMapView()
    private let marker             = MKPointAnnotation()
    
    
    // ******************** Constructors **************
    override init() {
        super.init()
    }
    override init(layer: Any) {
        super.init(layer: layer)
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    // ******************** Methods *******************
    override func update(cmd: String) {
        guard let tile = control else { return }
        
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
            
            tile.addSubview(map)
        } else if (cmd == Helper.REDRAW) {
            setNeedsDisplay()
        }
    }
    override func update<T>(prop: String, value: T) {
        if (prop == "value") {
            
        }
    }    
    
    
    // ******************** Redraw ********************
    override func draw(in ctx: CGContext) {
        super.draw(in: ctx)
        guard let tile = control else { return }
        
        UIGraphicsPushContext(ctx)
        
        width   = self.frame.width
        height  = self.frame.height
        size    = width < height ? width : height
        centerX = width * 0.5
        centerY = height * 0.5
        
        // Background
        let path = UIBezierPath(roundedRect: bounds, cornerRadius: size * 0.025)
        ctx.setFillColor(tile.bkgColor.cgColor)
        ctx.addPath(path.cgPath)
        ctx.fillPath()
        
        let smallFont  = UIFont.init(name: "Lato-Regular", size: size * 0.06)
        
        // Tile Title
        drawText(label   : tile.titleLabel,
                 font    : smallFont!,
                 text    : tile.title,
                 frame   : CGRect(x: size * 0.05, y: size * 0.05, width: width - size * 0.1, height: size * 0.08),
                 fgdColor: tile.fgdColor,
                 bkgColor: tile.bkgColor,
                 radius  : 0,
                 align   : tile.titleAlignment)
        
        // Tile Text
        if (tile.textVisible) {
            drawText(label   : tile.textLabel,
                     font    : smallFont!,
                     text    : tile.text,
                     frame   : CGRect(x: size * 0.05, y: height - size * 0.11, width: width - size * 0.1, height: size * 0.08),
                     fgdColor: tile.fgdColor,
                     bkgColor: tile.bkgColor,
                     radius  : 0,
                     align   : tile.textAlignment)
        } else {
            tile.textLabel.textColor = UIColor.clear
        }
        
        // Map
        let location         = CLLocationCoordinate2D(latitude: tile.location.latitude, longitude: tile.location.longitude)
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location, 100, 100)
        let marker           = MKPointAnnotation()
        marker.coordinate    = CLLocationCoordinate2D(latitude: tile.location.latitude, longitude: tile.location.longitude)
        marker.title         = tile.location.name
        map.frame            = CGRect(x: size * 0.05, y: size * 0.15, width: width * 0.9, height: height - size * (tile.textVisible ? 0.27 : 0.205))
        map.setRegion(coordinateRegion, animated: true)
        map.setCenter(location, animated: true)
        
        UIGraphicsPopContext()
    }
}

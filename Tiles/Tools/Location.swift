//
//  Location.swift
//  Tiles
//
//  Created by Gerrit Grunwald on 29.09.17.
//  Copyright © 2017 Gerrit Grunwald. All rights reserved.
//
import UIKit


class Location {
    public enum CardinalDirection {
        case N(String, Double, Double)
        case NNE(String, Double, Double)
        case NE(String, Double, Double)
        case ENE(String, Double, Double)
        case E(String, Double, Double)
        case ESE(String, Double, Double)
        case SE(String, Double, Double)
        case SSE(String, Double, Double)
        case S(String, Double, Double)
        case SSW(String, Double, Double)
        case SW(String, Double, Double)
        case WSW(String, Double, Double)
        case W(String, Double, Double)
        case WNW(String, Double, Double)
        case NW(String, Double, Double)
        case NNW(String, Double, Double)
    }
    var N   = CardinalDirection.N("North", 348.75, 11.25)
    var NNE = CardinalDirection.NNE("North North-East", 11.25, 33.75)
    var NE  = CardinalDirection.NE("North-East", 33.75, 56.25)
    var ENE = CardinalDirection.ENE("East North-East", 56.25, 78.75)
    var E   = CardinalDirection.E("East", 78.75, 101.25)
    var ESE = CardinalDirection.ESE("East South-East", 101.25, 123.75)
    var SE  = CardinalDirection.SE("South-East", 123.75, 146.25)
    var SSE = CardinalDirection.SSE("South South-East", 146.25, 168.75)
    var S   = CardinalDirection.S("South", 168.75, 191.25)
    var SSW = CardinalDirection.SSW("South South-West", 191.25, 213.75)
    var SW  = CardinalDirection.SW("South-West", 213.75, 236.25)
    var WSW = CardinalDirection.WSW("West South-West", 236.25, 258.75)
    var W   = CardinalDirection.W("West", 258.75, 281.25)
    var WNW = CardinalDirection.WNW("West North-West", 281.25, 303.75)
    var NW  = CardinalDirection.NW("North-West", 303.75, 326.25)
    var NNW = CardinalDirection.NNW("North North-West", 326.25, 348.75)
    
    var name      : String
    var timestamp : Date
    var latitude  : Double
    var longitude : Double
    var altitude  : Double
    var info      : String
    var color     : UIColor
    var zoomLevel : Int {
        didSet {
            zoomLevel = Helper.clamp(min: 0, max: 17, value: zoomLevel)
        }
    }
    
    convenience init() {
        self.init(latitude: 0, longitude: 0, altitude: 0, timestamp: Date(), name: "", info: "", color: Helper.BLUE)
    }
    convenience init(latitude:Double, longitude:Double) {
        self.init(latitude: latitude, longitude:longitude, altitude: 0, timestamp:Date(), name: "", info: "", color: Helper.BLUE)
    }
    convenience init(latitude:Double, longitude:Double, name:String) {
        self.init(latitude: latitude, longitude: longitude, altitude:0, timestamp: Date() ,name: name, info: "", color: Helper.BLUE);
    }
    convenience init(latitude:Double, longitude:Double, name:String, color:UIColor) {
        self.init(latitude:latitude, longitude:longitude, altitude:0, timestamp:Date() ,name:name, info:"", color:color);
    }
    convenience init(latitude:Double, longitude:Double, name:String, info:String) {
        self.init(latitude:latitude, longitude:longitude, altitude:0, timestamp:Date() ,name:name, info:info, color:Helper.BLUE);
    }
    convenience init(latitude:Double, longitude:Double, name:String, info:String, color:UIColor) {
        self.init(latitude:latitude, longitude:longitude, altitude:0, timestamp:Date() ,name:name, info:info, color:color);
    }
    convenience init(latitude:Double, longitude:Double, altitude:Double, name:String) {
        self.init(latitude:latitude, longitude:longitude, altitude:altitude, timestamp:Date(), name:name, info:"", color:Helper.BLUE);
    }
    convenience init(latitude:Double, longitude:Double, altitude:Double, timestamp:Date, name:String) {
        self.init(latitude:latitude, longitude:longitude, altitude:altitude, timestamp:timestamp, name:name, info:"", color:Helper.BLUE);
    }
    init(latitude:Double, longitude:Double, altitude:Double, timestamp:Date, name:String, info:String, color:UIColor) {
        self.latitude  = latitude
        self.longitude = longitude
        self.altitude  = altitude
        self.timestamp = timestamp
        self.name      = name
        self.info      = info
        self.color     = color
        self.zoomLevel = 10
    }
    
    
    func getTimestampInSeconds() -> TimeInterval { return timestamp.timeIntervalSince1970 }
    
    func set(latitude: Double, longitude: Double) {
        self.latitude  = latitude
        self.longitude = longitude
        timestamp      = Date()
    }
    func set(latitude: Double, longitude: Double, altitude: Double, timestamp: Date) {
        self.latitude  = latitude
        self.longitude = longitude
        self.altitude  = altitude
        self.timestamp = timestamp
    }
    func set(latitude: Double, longitude: Double, altitude: Double, timestamp: Date, info: String) {
        self.latitude  = latitude
        self.longitude = longitude
        self.altitude  = altitude
        self.timestamp = timestamp
        self.info      = info
    }
    func set(location: Location) {
        latitude  = location.latitude
        longitude = location.longitude
        altitude  = location.altitude
        timestamp = location.timestamp
        name      = location.name
        info      = location.info
        color     = location.color
        zoomLevel = location.zoomLevel
    }
    
    func getDistanceTo(location: Location) -> Double {
        return calcDistanceInMeter(p1: self, p2: location)
    }
    
    func isWithinRangeOf(location: Location, meters: Double) -> Bool {
        return getDistanceTo(location: location) < meters
    }
    
    func calcDistanceInMeter(p1: Location, p2: Location) -> Double {
        return calcDistanceInMeter(lat1: p1.latitude, lon1: p1.longitude, lat2: p2.latitude, lon2: p2.longitude)
    }
    func calcDistanceInMeter(lat1: Double, lon1: Double, lat2: Double, lon2: Double) -> Double {
        let earthRadius = 6_371_000.0 // m
        let lat1Rad     = Helper.toRadians(deg: lat1)
        let lat2Rad     = Helper.toRadians(deg: lat2)
        let deltaLatRad = Helper.toRadians(deg: lat2 - lat1)
        let deltaLonRad = Helper.toRadians(deg: lon2 - lon1)
        
        let A = sin(deltaLatRad * 0.5) * sin(deltaLatRad * 0.5) + cos(lat1Rad) * cos(lat2Rad) * sin(deltaLonRad * 0.5) * sin(deltaLonRad * 0.5)
        let C = 2 * atan2(sqrt(A), sqrt(1-A))
        
        let distance = earthRadius * C
        
        return distance
    }
    
    func getBearingTo(location: Location) -> Double {
        return calcBearingInDegree(lat1: latitude, lon1: longitude, lat2: location.latitude, lon2: location.longitude)
    }
    func getBearingTo(latitude: Double, longitude: Double) -> Double {
        return calcBearingInDegree(lat1: self.latitude, lon1: self.longitude, lat2: latitude, lon2: longitude)
    }
    
    func calcBearingInDegree(lat1: Double, lon1: Double, lat2: Double, lon2: Double) -> Double {
        let lat1Rad     = Helper.toRadians(deg: lat1)
        let lon1Rad     = Helper.toRadians(deg: lon1)
        let lat2Rad     = Helper.toRadians(deg: lat2)
        let lon2Rad     = Helper.toRadians(deg: lon2)
        var deltaLonRad = lon2Rad - lon1Rad;
        let deltaPhi = log(tan(lat2Rad * 0.5 + .pi * 0.25) / tan(lat1Rad * 0.5 + .pi * 0.25))
        if (abs(deltaLonRad) > .pi) {
            if (deltaLonRad > 0) {
                deltaLonRad = -(2.0 * .pi - deltaLonRad)
            } else {
                deltaLonRad = (2.0 * .pi + deltaLonRad)
            }
        }
        let bearing = (Helper.toDegrees(rad: atan2(deltaLonRad, deltaPhi)) + 360.0).truncatingRemainder(dividingBy: 360.0)
        return bearing
    }
}

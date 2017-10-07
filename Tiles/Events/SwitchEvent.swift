//
//  SwitchEvent.swift
//  Tiles
//
//  Created by Gerrit Grunwald on 06.10.17.
//  Copyright © 2017 Gerrit Grunwald. All rights reserved.
//

import UIKit

class SwitchEvent {
    var src  : Tile
    var type : SwitchEventType
    
    init(src : Tile, type : SwitchEventType) {
        self.src  = src
        self.type = type
    }
}

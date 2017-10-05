//
//  TileEvent.swift
//  Tiles
//
//  Created by Gerrit Grunwald on 04.10.17.
//  Copyright © 2017 Gerrit Grunwald. All rights reserved.
//

import UIKit


class TileEvent {
    var src  : Tile
    var type : TileEventType
    
    init(src : Tile, type : TileEventType) {
        self.src  = src
        self.type = type
    }
}

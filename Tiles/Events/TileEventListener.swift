//
//  EventListener.swift
//  Tiles
//
//  Created by Gerrit Grunwald on 04.10.17.
//  Copyright © 2017 Gerrit Grunwald. All rights reserved.
//

import UIKit

protocol TileEventListener: class {
    
    func onTileEvent(event : TileEvent)
}

//
//  Skin.swift
//  Tiles
//
//  Created by Gerrit Grunwald on 29.09.17.
//  Copyright © 2017 Gerrit Grunwald. All rights reserved.
//

import UIKit


class Skin :CALayer {
    public weak var control :Tile?
    
    func update(cmd: String) {
        preconditionFailure("This method must be overridden")
    }
    
    func update<T>(prop: String, value: T) {
        preconditionFailure("This method must be overridden") 
    }
}

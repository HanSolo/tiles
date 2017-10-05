//
//  SectionEvent.swift
//  Tiles
//
//  Created by Gerrit Grunwald on 04.10.17.
//  Copyright © 2017 Gerrit Grunwald. All rights reserved.
//

import UIKit

class SectionEvent {
    var src  : Section
    var type : SectionEventType
    
    init(src : Section, type : SectionEventType) {
        self.src  = src
        self.type = type
    }
}

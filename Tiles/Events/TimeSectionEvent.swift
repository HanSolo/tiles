//
//  TimeEvent.swift
//  Tiles
//
//  Created by Gerrit Grunwald on 06.10.17.
//  Copyright © 2017 Gerrit Grunwald. All rights reserved.
//

import UIKit

class TimeSectionEvent {
    var src  : TimeSection
    var type : TimeSectionEventType
    
    init(src : TimeSection, type : TimeSectionEventType) {
        self.src  = src
        self.type = type
    }
}

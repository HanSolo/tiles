//
//  SectionEventListener.swift
//  Tiles
//
//  Created by Gerrit Grunwald on 04.10.17.
//  Copyright © 2017 Gerrit Grunwald. All rights reserved.
//

import UIKit

protocol SectionEventListener: class {
    
    func onSectionEvent(event : SectionEvent)
}

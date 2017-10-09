//
//  ChartDataEventListener.swift
//  Tiles
//
//  Created by Gerrit Grunwald on 08.10.17.
//  Copyright © 2017 Gerrit Grunwald. All rights reserved.
//

import UIKit

protocol ChartDataEventListener : class {
    
    func onChartDataEvent(event : ChartDataEvent)
}

//
//  Date+EasyInitializer.swift
//  Tiles
//
//  Created by Gerrit Grunwald on 06.10.17.
//  Copyright © 2017 Gerrit Grunwald. All rights reserved.
//

import UIKit

extension Date {
    init?(day: Int, month: Int, year: Int, hour: Int, minute: Int, second: Int) {
        let cal = Calendar.current
        var dateComponents    = DateComponents()
        dateComponents.year   = year
        dateComponents.month  = month
        dateComponents.day    = day
        dateComponents.hour   = hour
        dateComponents.minute = minute
        dateComponents.second = second
        let date = cal.date(from: dateComponents)
        self = date!
    }
}

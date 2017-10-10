//
//  UIColor+RGBComponents.swift
//  Tiles
//
//  Created by Gerrit Grunwald on 10.10.17.
//  Copyright © 2017 Gerrit Grunwald. All rights reserved.
//

import UIKit

extension UIColor {
    var coreImageColor: CIColor {
        return CIColor(color: self)
    }
    var components: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        let coreImageColor = self.coreImageColor
        return (coreImageColor.red, coreImageColor.green, coreImageColor.blue, coreImageColor.alpha)
    }
}

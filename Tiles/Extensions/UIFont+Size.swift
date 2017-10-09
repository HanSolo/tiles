//
//  UIFont+Size.swift
//  Tiles
//
//  Created by Gerrit Grunwald on 09.10.17.
//  Copyright © 2017 Gerrit Grunwald. All rights reserved.
//

import UIKit

extension UIFont {
    func sizeOfString (string: String, constrainedToWidth width: Double) -> CGSize {
        return string.boundingRect(with      : CGSize(width: width, height: Double.greatestFiniteMagnitude),
                                   options   : NSStringDrawingOptions.usesLineFragmentOrigin,
                                   attributes: [NSAttributedStringKey.font: self],
                                   context   : nil).size
    }
}

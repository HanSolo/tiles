//
//  Dictionary+CustomConstructor.swift
//  Tiles
//
//  Created by Gerrit Grunwald on 10.10.17.
//  Copyright © 2017 Gerrit Grunwald. All rights reserved.
//

import UIKit

extension Dictionary {
    public init(keyValuePairs: [(Key, Value)]) {
        self.init()
        for pair in keyValuePairs {
            self[pair.0] = pair.1
        }
    }
}

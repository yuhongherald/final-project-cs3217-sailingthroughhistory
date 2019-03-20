//
//  Path.swift
//  SailingThroughHistory
//
//  Created by Jason Chong on 18/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import UIKit

struct Path: Hashable {
    let fromObject: GameObject
    let toObject: GameObject
    var modifiers = [VolatileModifier]()

    static func == (lhs: Path, rhs: Path) -> Bool {
        return (lhs.fromObject, lhs.toObject) == (rhs.fromObject, rhs.toObject)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(fromObject)
        hasher.combine(toObject)
    }
}
